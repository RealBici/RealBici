//
//  String+RealBici.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import CommonCrypto

public extension String {
    
    /// Localize String을 반환
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /**
     사용자ID 패턴 검사기
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    func isValidUserId(min:Int = 6,max:Int = 12) -> Bool {
        let emailRegEx = "[A-Z0-9a-z]{\(min),\(max)}"
        return patternMatch(pattern: emailRegEx)
    }

    /**
     Email 패턴 검사기
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    var isValidEmail:Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        return patternMatch(pattern: emailRegEx)
    }

    /**
     도메인 패턴 검사기(###.$$$)
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    var isValidDomain:Bool {
        return patternMatch(pattern: "[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    }

    /**
     비밀번호 패턴 검사기
     - 문자,숫자,특문 조합
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    var isValidPassword:Bool {
        return patternMatch(pattern: "^(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*?~])[A-Za-z\\d!@#$%^&*?~]{1,}")
    }

    /**
     비밀번호 길이 검사기
     - 기본값 : 최소 8자리, 최대 20자리
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    func isValidPasswordSize(min:Int = 8,max:Int = 12) -> Bool {
        return patternMatch(pattern: "^(?=.*[a-z])(?=.*\\d)(?=.*[!@#$%^&*?~])[A-Za-z\\d!@#$%^&*?~]{\(min),\(min)}")
    }
    
    /// 휴대폰 번호 정규식 01X(016789)나머지 7,8자리
    var isValidPhoneNumber:Bool {
        return patternMatch(pattern: "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$")
    }
    
    /**
     정규식 패턴 검사기
     
     - Returns: 패턴 일치(true), 불일치(false)
     */
    private func patternMatch(pattern: String) -> Bool {
        let match = NSPredicate(format: "SELF MATCHES %@", pattern)
        return match.evaluate(with: self)
    }

    /// 버전 체크
    func isVersionNewer(currentVersion: String) -> Bool {
        if self.compare(currentVersion, options: .numeric) == .orderedDescending {
            return true
        }
        return false
    }

    /// 용량 단위표현(MB)
    var toSizeString:String {
        guard let num = Double(self) else { return "\(self)" }

        let result = num > 999999 ? "\(round((num / 1000000) * 10) / 10) MB" : "\(round((num / 1000) * 10) / 10) KB"
        return result
    }

    /// Number 포맷대로 채워넣기
    /// "12345".formattedString("XX-XX-X")
    func formattedString(_ pattern: String = "XXX-XXXX-XXXX", _ char: CharacterSet = CharacterSet.decimalDigits) -> String {
        let cleanString = self.components(separatedBy: char.inverted).joined()
        let mask = pattern

        var result = ""
        var index = cleanString.startIndex
        for ch in mask where index < cleanString.endIndex {
            if ch == "X" {
                result.append(cleanString[index])
                index = cleanString.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    var isAllSameChar:Bool {
        let chars = Array(self)
        let first = chars[0]

        for c in chars {
            if first != c {
                return false
            }
        }

        return true
    }

    /// String to Dictoinary
    var dict:[String: Any] {
        if let data = self.data(using: .utf8) {
            return data.dict
        }
        return [:]
    }

    // MARK: SubString
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[...toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex...endIndex])
    }

    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }

    // MARK: 초성변환
    /// 초성 변환(한글만)
    var chosung:String {
        let nsStr: NSString = NSString(string: self)
        let chosung = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
        var _out: NSString = ""
        for i in 0 ..< nsStr.length {
            let oneChar: UniChar = nsStr.character(at: i)
            if oneChar >= 0xAC00 && oneChar <= 0xD7A3 {
                let firstCodeValue = Int((oneChar - 0xAC00) / (28*21))
                _out = _out.appendingFormat("%@", chosung[firstCodeValue])
            }
        }
        return String(_out)

    }
    /// Date를 Format String에 맞춰 반환
    // "yyyy-MM-dd HH:mm:ss".toDateFormat(date:Date())
    func toDateFormatKR(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.amSymbol = "오전"
        formatter.pmSymbol = "오후"
        let defaultTimeZoneStr = formatter.string(from: date)

        return defaultTimeZoneStr
    }
    
    func toDateFormat(date: Date, timeZone:TimeZone = TimeZone.current, locale:Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = self
        formatter.timeZone = timeZone
        formatter.locale = locale
        
        let defaultTimeZoneStr = formatter.string(from: date)

        return defaultTimeZoneStr
    }
    
    /// DateString을 Date로 변환
    /// "2021-05-01".toDate(format:"yyyy.MM.dd")
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss", timeZone:TimeZone = TimeZone.current, locale:Locale = Locale.current) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        dateFormatter.locale = locale

        return dateFormatter.date(from: self) ?? Date()
    }
    
    /// DateString을 다른 포맷의 DateString으로 변환
    func toDateString(format: String = "yyyy.MM.dd") -> String {
        return format.toDateFormat(date: self.toDate())
    }
    
    /// Date를 UTC로 Dateformat String으로 변환
    /// - Parameters:
    ///   - date: 변환할 Date
    ///   - locale: 적용할 Locale
    /// - Returns: 적용된 DateFormat String
    func toUTCDateFormat(date:Date, locale:Locale = Locale.current) -> String {
        let timezone = TimeZone(abbreviation: "UTC") ?? TimeZone.current
        return toDateFormat(date: date, timeZone: timezone, locale: locale)
    }
    
    /// 가운데 ** 마스킹 처리
    var maskingPhoneNoMid:String {
        let cnt = count
        guard cnt > 9 else { return self }
        return String(self.enumerated().map { index, char in
            return [0, 1, 2, cnt - 1, cnt - 2, cnt - 3, cnt - 4].contains(index) ? char : "*"
        })
    }
    /// 이메일 마스킹 처리
    var maskingEmail:String {
        guard self.contains("@") else { return self }

        guard let front = self.components(separatedBy: "@").first,
            let back = self.components(separatedBy: "@").last else { return self}

        let masked = String(front.enumerated().map { index, char in
            return index > 2 ? "*" : char
        })

        return "\(masked)@\(back)"
    }
    
    /// 숫자인지 체크
    var isNumber:Bool {
        if Int(self) != nil {
            return true
        }
        return false
    }
    
    // to Int
    var int:Int {
        return Int(self) ?? 0
    }
}
