//
//  ServiceManager.swift
//  
//
//  Created by 임병철 on 2021/05/03.
//

import Foundation

/*
 프로젝트에 import 후 상속 받아서 사용할것
 override 대상 : var instance:상속class이름
 
 예시)
 import msUtil

 class UploadManager:ServiceManager {
     
     class override var instance: UploadManager {
         return UploadManager()
     }
     
     func 서비스api함수.. {
     }
 }
 
 사용예)
 UploadManager.instance.서비스api함수 {
    처리..
 }

 */
open class ServiceManager: NSObject {
    let CONNECTION_TIME_OUT = 30.0

    open class var instance: ServiceManager {
        return ServiceManager()
    }
    
    // MARK: - Request Module

    /// http 요청 및 응답 처리
    public func requestHttp(method: HTTPMethod, url: String, header: [String: String] = [String: String](), parameters: [String: Any] = [String: Any](), showLoading: Bool = true,  showLog: Bool = true, onCompletion:@escaping (_ success: Bool, _ dict: [String: Any]?,_ data:Data?  ,_ statusCode: Int) -> Void) {
        guard let urlString = URL(string: url) else { onCompletion(false, nil, nil, ConnectionError.NetworkError.code); return }
        
        if showLoading {
            RealBici.shared.showLoading()
        }
        
        if showLog {
            #if DEBUG
            print("\n[REQUEST]===============================================================\n" +
                "METHOD : \(method)\n" +
                "URI    : \(url)\n" +
                "HEADER : \(header)\n" +
                "PARAM  : \(parameters)\n" +
                "===============================================================[REQUEST]"
            )
            #endif
        }
        
        var request = URLRequest(url: urlString)
        request.httpMethod = method.rawValue
        for key in header.keys {
            request.setValue(header[key], forHTTPHeaderField: key)
        }

        if parameters.count > 0 {
            do {
                var param: Data?
                param = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0)) as Data?
                request.httpBody = param
                switch method {
                case .POST, .GET, .DELETE:
                    request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
                //                    request.setValue("application/json", forHTTPHeaderField: "Accept")
                case .PUT:
                    request.setValue("text/JSON; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                onCompletion(false, nil, nil, ConnectionError.FailToJson.code)
            }
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = CONNECTION_TIME_OUT
        sessionConfig.timeoutIntervalForResource = CONNECTION_TIME_OUT
        let session = URLSession(configuration: sessionConfig)

        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if showLoading {
                RealBici.shared.hideLoading()
            }
            
            guard error == nil
                else { onCompletion(false, nil, data, ConnectionError.NetworkError.code); return }

            guard let HTTPResponse = response as? HTTPURLResponse
                else { onCompletion(false, nil, data, ConnectionError.NetworkError.code); return }

            let statCode = HTTPResponse.statusCode

            if let repdata = data {
                do {
                    if let result = try JSONSerialization.jsonObject(with: repdata, options: .allowFragments) as? [String: Any] {
                        onCompletion(true, result, data, statCode)
                    } else {
                        onCompletion(true, nil, data, statCode)
                    }
                } catch {
                    onCompletion(true, nil, data, statCode)
                }
            } else {
                onCompletion(true, nil, data, statCode)
            }
        })
        
        task.resume()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    //MARK: Multipart
    /// Multipart-formdata 업로드 함수, filePath는 struct에 UploadVO Protocol 구현할것
    public func requestMultipart(url:String, boundary:String, headers:[String:String] = [:], parameters: [String:Any] = [:], filePath:[UploadVO], completion: @escaping(Any?, Error?, Bool)->Void) {
        
        let stringUrl = url
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        #if DEBUG
        print("\n\ncomplete Url :-------------- ",stringUrl," \n\n-------------: complete Url")
        #endif
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if headers.count > 0 {
            #if DEBUG
            print("\n\nHeaders :-------------- ",headers as Any,"\n\n --------------: Headers")
            #endif
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        if parameters.count > 0 {
            for(key, value) in parameters {
                // Add the reqtype field and its value to the raw http request data
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
        
        for ufile in filePath {
            guard ufile.data.count > 0 else { continue }
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(ufile.key)\"; filename=\"\(ufile.name)\"\r\n".data(using: .utf8)!)
            //            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(ufile.mimeType)\r\n\r\n".data(using: .utf8)!)
            data.append(ufile.data)
        }
        
        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: data, completionHandler: { data, response, error in
            
            if let checkResponse = response as? HTTPURLResponse{
                if checkResponse.statusCode == 200{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) else {
                        completion(nil, error, false)
                        return
                    }
                    let jsonString = String(data: data, encoding: .utf8)!
                    #if DEBUG
                    print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    print(json)
                    #endif
                    completion(json, nil, true)
                }else{
                    guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                        completion(nil, error, false)
                        return
                    }
                    let jsonString = String(data: data, encoding: .utf8)!
                    #if DEBUG
                    print("\n\n---------------------------\n\n"+jsonString+"\n\n---------------------------\n\n")
                    print(json)
                    #endif
                    completion(json, nil, false)
                }
            }else{
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completion(nil, error, false)
                    return
                }
                completion(json, nil, false)
            }
            
        }).resume()
        
    }

}

/// 연결 오류 타입
public enum ConnectionError: Int {
    case NetworkError = -1
    case FailToJson = -2

    func getMsg() -> String {
        switch self {
        case .NetworkError:
            return "Network Error"
        case .FailToJson:
            return "Fail to get Json"
        }
    }

    var code:Int {
        return self.rawValue
    }
}

/// Http 요청 메소드 타입
public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public protocol UploadVO {
    var key:String { get set }
    var name:String { get set }
    var path:String { get set }
    var mimeType:String { get set }
}

public extension UploadVO {
    var data:Data {
        guard let fileData = NSData(contentsOfFile: path) as Data?, fileData.count > 0 else { return Data() }
        return fileData
    }
}
