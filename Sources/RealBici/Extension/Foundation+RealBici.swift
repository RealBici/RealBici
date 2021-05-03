//
//  File.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation

//MARK- Data Extension
public extension Data {
    /// 바이너리를 Dictionary로
    var dict:[String: Any] {
        do {
            if let result = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
                return result
            } else {
                return [:]
            }
        } catch let error {
            print("\(error.localizedDescription)")
            return [:]
        }
    }
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
//MARK:- UserDefaults
public extension UserDefaults {
    /// String 가져오기
    func string(_ key: StrKey, _ defaultValue: String = "") -> String {
        guard let val = self.string(forKey: key.key) else { return defaultValue }
        return val
    }

    /// Bool 가져오기
    func bool(_ key: StrKey) -> Bool {
        return self.bool(forKey: key.key)
    }

    /// 데이터 삽입
    func set(_ val: Any, _ key: StrKey) {
        self.set(val, forKey: key.key)
        self.synchronize()
    }

}

public extension Int {
    /// 원화 단위로 변환
    func toCurrency(_ unit: String = "원") -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "ko_KR")
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = true

        nf.positiveFormat = "###,###"
        guard let result = nf.string(from: NSNumber(value: self)) else {
            return "\(self)"
        }

        return "\(result)\(unit)"
    }
    
    /// string으로 변환
    var string:String {
        return "\(self)"
    }
}

public extension Date {
    
    /// 오늘인지 여부
    var isToday:Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// 어제인지 여부
    var isYesterday:Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    
    /// 날짜 연산
    /// - Parameters:
    ///   - type: Calendar Component
    ///   - value: int
    /// - Returns: 연산 적용된 Date
    func adding(type: Calendar.Component, value:Int) -> Date {
        return Calendar.current.date(byAdding: type, value: value, to: self)!
    }
    
    
    /// Date Component 추출
    /// - Parameter comp: Calendar Component
    /// - Returns: 해당 Component
    func getComp(_ comp:Calendar.Component) -> Int {
        return Calendar.current.component(comp, from: self)
    }
}

public extension FileManager {
    static var tempDirectory:URL {
        return NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    }
    
    static func getDirectory(dir:SearchPathDirectory = .documentDirectory) -> URL {
        return FileManager.default.urls(for: dir, in: .userDomainMask)[0]
    }
}

public extension Bundle {
    /// Bundle Info
    static func info(_ info:AppInfo) -> String {
        return info.info
    }
}

public enum AppInfo:String {
    /// App Version
    case Version = "CFBundleShortVersionString"
    /// App BuildVersion
    case BuildVersion = "CFBundleVersion"
    /// App Name
    case AppName = "CFBundleName"
    /// Minimum OS Version
    case MinOSVer = "MinimumOSVersion"
    /// App Bundle Id
    case BundleId = "CFBundleIdentifier"
    
    var key:String {
        return rawValue
    }
    
    var info:String {
        guard let dictionary = Bundle.main.infoDictionary
            , let version = dictionary[key] as? String else {
                return ""
        }
        return version
    }
}
