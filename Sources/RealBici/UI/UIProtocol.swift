//
//  UIProtocol.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import UIKit

public protocol Storyboarded {
    static func instantiate(_ name: StrKey) -> Self
}

public extension Storyboarded where Self: UIViewController {
    static func instantiate(_ name: StrKey) -> Self {
        return instantiate(name.key)
    }
    
    /// Instantiate StoryBoard which named "Main"
    /// (ex. let vc = SomeVC.instantiateMain)
    static var instantiateMain:Self {
        return instantiate("Main")
    }
    
    static func instantiate(_ name: String) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: className) as! Self
        return vc
    }

}

public protocol TableCell {
    static func instantiate(_ tableView: UITableView) -> Self
}

public extension TableCell where Self: UITableViewCell {
    static func instantiate(_ tableView: UITableView) -> Self {

        let fullName = NSStringFromClass(self)

        let className = fullName.components(separatedBy: ".")[1]

        let cell = tableView.dequeueReusableCell(withIdentifier: className) as! Self

        return cell
    }
}

public protocol CollectionCell {
    static func instantiate(_ collView: UICollectionView, _ indexPath: IndexPath) -> Self
}

public extension CollectionCell where Self: UICollectionViewCell {
    static func instantiate(_ collView: UICollectionView, _ indexPath: IndexPath) -> Self {

        let fullName = NSStringFromClass(self)

        let className = fullName.components(separatedBy: ".")[1]

        return collView.dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as! Self
    }
}

/// 키보드 팝업 시 버튼을 키보드 위로 설정할수 있게 해주는 Protocol
public protocol ButtonAboveKeyboard {
    var constraint: NSLayoutConstraint {get}
    var notchMargin: CGFloat {get}
    func keyboardNotification(notification: Notification)
}

public extension ButtonAboveKeyboard where Self: UIViewController {
    var notchMargin:CGFloat {
        guard UIDevice.current.hasNotch else { return 0 }
        
        guard UIDevice.current.orientation == .portrait else { return 21 }
        
        return 34
    }

    func setKbdObs(_ show: Bool = true, selector: Selector) {
        let name = show ? UIResponder.keyboardWillShowNotification : UIResponder.keyboardWillHideNotification
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }

    func keyboardNotification(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let moveUp = (notification.name == UIResponder.keyboardWillShowNotification)

        constraint.constant = moveUp ? (keyboardHeight - notchMargin) * -1 : 0

        if UserDefaults.standard.float(forKey: "kbdHeight") < 200 {
            UserDefaults.standard.set((keyboardHeight - notchMargin), forKey: "kbdHeight")
            UserDefaults.standard.synchronize()
        }

        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: {
                        [unowned self] in
                        self.view.layoutIfNeeded()
            },
                       completion: nil
        )
    }

    func releaseObs() {
        NotificationCenter.default.removeObserver(self)
    }
}

/// View의 부분 라운딩 처리를 위한 프로토콜
public protocol CornerRoundProtocol {
    var corners:UIRectCorner { get set }
    var radius: CGFloat { get set }
    var bdWidth:CGFloat { get set }
    var bdColor:UIColor { get set }
    var commaSeparatedCorners: String { get set }
}

public extension CornerRoundProtocol where Self:UIView {
    func setLayoutSubVw() {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.borderWidth = bdWidth
            layer.borderColor = bdColor.cgColor
            
            layer.maskedCorners = commaSeparatedCorners.toCommaCACorner
        } else {
            partialCornerRadius(corners: corners, radius: radius)
            if bdWidth > 0 {
                partialBorderStroke(borderWidth: bdWidth, borderColor: bdColor, corners: corners, radius: radius)
            }
        }
    }
    
    func updateVw() {
        layer.mask = nil
        layoutSubviews()
    }
}
