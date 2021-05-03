//
//  File.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import UIKit

@IBDesignable public class DesignView:UIView {
}

@IBDesignable public class DesignTableVw:UITableView {
}

@IBDesignable public class DesignButton:UIButton {
    
    /// 버튼 텍스트를 localized String으로 적용
    @IBInspectable public var localizedKey:String = "" {
        didSet {
            guard localizedKey != "" else { return }
            setTitle(localizedKey.localized, for: .normal)
        }
    }
}

@IBDesignable public class DesignLabel:UILabel {
    /// Label 텍스트를 localized String으로 적용
    @IBInspectable public var localizedKey:String = "" {
        didSet {
            guard localizedKey != "" else { return }
            text = localizedKey.localized
        }
    }
}

public extension String {
    var toRectCorner:UIRectCorner {
        switch self {
        case "topLeft", "topleft": return .topLeft
        case "topRight", "topright": return .topRight
        case "botLeft", "botleft": return .bottomLeft
        case "botRight", "botright": return .bottomRight
        default: return []
        }
    }

    var toCommaRectCorner:UIRectCorner {
        guard self != "" else { return [] }

        var result:UIRectCorner = []
        let _ = self.components(separatedBy: ",").map{ result.insert($0.toRectCorner) }

        return result
    }
    
    var toCACorner:CACornerMask {
        switch self {
        case "topLeft", "topleft": return .layerMinXMinYCorner
        case "topRight", "topright": return .layerMaxXMinYCorner
        case "botLeft", "botleft": return .layerMinXMaxYCorner
        case "botRight", "botright": return .layerMaxXMaxYCorner
        default: return []
        }
    }
    
    var toCommaCACorner:CACornerMask {
        guard self != "" else { return [] }

        var result:CACornerMask = []
        let _ = self.components(separatedBy: ",").map{ result.insert($0.toCACorner) }

        return result
    }
}
