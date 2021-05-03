//
//  Protocols.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import UIKit

/// String key Protocol
public protocol StrKey {
    var key:String { get }
}

/**
 ValueObject <-> Dictionary 상호 전환하는 Protocol
 
 - init(dic:[String:Any]): Dictionary -> ValueObject
 - var category:StrKey : ValueObject -> Dictionary 변환시 필요한 카테고리
 - func val(_ key:StrKey) -> Any : ValueObject -> Dictionary 변환시 키에 매핑되는 값을 반환
 */
public protocol VOChanger {
    /**
     Dictionary -> ValueObject
     */
    init(dic: [String: Any])
    /**
     ValueObject -> Dictionary 변환시 필요한 카테고리
     */
    var keys: [StrKey] {get}
    /**
     ValueObject -> Dictionary 변환시 키에 매핑되는 값을 반환
     */
    func val(_ key: StrKey) -> Any
    /**
     ValueObject -> Dictionary 변환
     */
    func toDic() -> [String: Any]
}

public extension VOChanger {
    /**
     ValueObject -> Dictionary 변환
     */
    var toDict:[String: Any] {
        var result = [String: Any]()

        for k in keys {
            var target = [k.key: val(k)]
            if let v = val(k) as? VOChanger {
                target = [k.key: v.toDic()]
            }
            if let vrr = val(k) as? [VOChanger] {
                target = [k.key: vrr.map {$0.toDic()}]
            }

            result.update(other: target)
        }

        return result
    }
}


/// Decodable Http 매핑
protocol MiniHttp {
    static func getResult(urlString:String, comp:@escaping((Self) -> Void))
}

extension MiniHttp where Self:Decodable {
    static func getResult(urlString:String, comp:@escaping((Self) -> Void)) {
        guard let url = URL(string: urlString) else { return }
        #if DEBUG
        print(urlString)
        #endif
        
        URLSession.shared.dataTask(with: url) { data, response, err in
            guard let d = data else { return }
            
            do {
                let rss = try JSONDecoder().decode(Self.self, from: d)
                DispatchQueue.main.async {
                    comp(rss)
                }
           } catch  {
                print("error : \(String(describing: error))")
            }
        }.resume()
    }
}
