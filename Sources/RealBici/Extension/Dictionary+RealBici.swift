//
//  Dictionary+RealBici.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import UIKit

//MARK:- Dictionary extension
public extension Dictionary {
    
    /// Merge Dictionary
    /// - Parameter other: other Dict
    mutating func update(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
    
    
    /// JSON 형식으로 print (Debugging 용)
    func toJson() {
        print(toJsonStr(.prettyPrinted))
    }
    
    /// JSON String으로 변환
    /// - Parameter opt: JSONSerialization Option
    /// - Returns: JSON String
    func toJsonStr(_ opt: JSONSerialization.WritingOptions = []) -> String {
        if let theJSONData = try?  JSONSerialization.data(withJSONObject: self, options: opt),
            let theJSONText = String(data: theJSONData, encoding: String.Encoding.utf8) {
            return theJSONText
        } else {
            return "{}"
        }
    }
}

public extension Dictionary where Key == String {
    func val(_ kvo: String, _ basic: Any = "") -> Any {
        return self[kvo] ?? basic
    }
    
    func string(_ kvo: String, _ basic: String = "") -> String {
        return self.val(kvo) as? String ?? basic
    }
    
    func double(_ kvo: String, _ basic: Double = 0) -> Double {
        guard let result = self.val(kvo) as? Double else {
            guard let string = self.val(kvo) as? String else {
                return basic
            }
            
            return Double(string) ?? basic
        }
        return result
    }
    
    func int(_ kvo: String, _ basic: Int = 0) -> Int {
        guard let result = self.val(kvo) as? Int else {
            guard let string = self.val(kvo) as? String else {
                return basic
            }
            
            return Int(string) ?? basic
        }
        return result
    }
    
    func bool(_ kvo: String, _ basic: Bool = false) -> Bool {
        return self.val(kvo) as? Bool ?? basic
    }
    
    func boolYN(_ kvo: String, _ basic: Bool = false) -> Bool {
        guard let result = self.val(kvo) as? String else {
            return basic
        }
        return result == "Y"
    }
    
    func array(_ kvo: String, _ basic: [[String: Any]] = []) -> [[String: Any]] {
        return self.val(kvo) as? [[String: Any]] ?? basic
    }
    
    func stringArray(_ kvo: String, _ basic: [String] = []) -> [String] {
        return self.val(kvo) as? [String] ?? basic
    }
    
    func dic(_ kvo: String, _ basic: [String: Any] = [:]) -> [String: Any] {
        return self.val(kvo) as? [String: Any] ?? basic
    }
}

public extension Dictionary where Key == String {
    func val(_ kvo: StrKey, _ basic: Any = "") -> Any {
        return self[kvo.key] ?? basic
    }
    
    func string(_ kvo: StrKey, _ basic: String = "") -> String {
        return self.val(kvo) as? String ?? basic
    }
    
    func double(_ kvo: StrKey, _ basic: Double = 0) -> Double {
        guard let result = self.val(kvo) as? Double else {
            guard let string = self.val(kvo) as? String else {
                return basic
            }
            
            return Double(string) ?? basic
        }
        return result
    }
    
    func int(_ kvo: StrKey, _ basic: Int = 0) -> Int {
        guard let result = self.val(kvo) as? Int else {
            guard let string = self.val(kvo) as? String else {
                return basic
            }
            
            return Int(string) ?? basic
        }
        return result
    }
    
    func bool(_ kvo: StrKey, _ basic: Bool = false) -> Bool {
        return self.val(kvo) as? Bool ?? basic
    }
    
    func boolYN(_ kvo: StrKey, _ basic: Bool = false) -> Bool {
        guard let result = self.val(kvo) as? String else {
            return basic
        }
        return result == "Y"
    }
    
    func array(_ kvo: StrKey, _ basic: [[String: Any]] = []) -> [[String: Any]] {
        return self.val(kvo) as? [[String: Any]] ?? basic
    }
    
    func stringArray(_ kvo: StrKey, _ basic: [String] = []) -> [String] {
        return self.val(kvo) as? [String] ?? basic
    }
    
    func dic(_ kvo: StrKey, _ basic: [String: Any] = [:]) -> [String: Any] {
        return self.val(kvo) as? [String: Any] ?? basic
    }
}
