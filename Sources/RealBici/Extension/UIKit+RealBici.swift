//
//  UIKit+RealBici.swift
//  
//
//  Created by 임병철 on 2021/04/29.
//

import Foundation
import UIKit

//MARK:- UIImage Extension
public extension UIImage {
    convenience init(_ img: StrKey) {
        self.init(named: img.key)!
    }
    
    class func image(_ img: StrKey) -> UIImage {
        return UIImage(named: img.key) ?? UIImage()
    }
    
    /// UIImage to base64 string
    var toBase64:String {
        return self.jpegData(compressionQuality:1)?.base64EncodedString() ?? ""
    }
    
    /// base64 string to UIImage
    class func fromBase64(_ string:String) -> UIImage {
        let imageData = Data.init(base64Encoded:string, options: .init(rawValue: 0))
        guard let data = imageData, let image = UIImage(data: data) else { return UIImage() }
        return image
    }
    
    /// rotate Image(ex. image.rotate(.pi))
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
    
    /// Image Deep copy
    var deepCopy:UIImage {
        guard let png = pngData(), let result = UIImage(data: png) else { return UIImage() }
        return result
    }
    
    /// 이미지를 파일로 저장
    func saveFile(pathUrl:URL, fileName:String) {
        guard fileName.lowercased().contains(".jpg") || fileName.lowercased().contains(".png") else { return }
        let filePath = pathUrl.appendingPathComponent(fileName)
        
        guard let data = fileName.lowercased().contains(".jpg") ? jpegData(compressionQuality: 1) : pngData() else { return }
        
        try? data.write(to: filePath)
    }
}

//MARK:- UIColor Extension
public extension UIColor {
    @available(iOS 11.0, *)
    convenience init(_ img: StrKey) {
        self.init(named: img.key)!
    }
    
    @available(iOS 11.0, *)
    class func color(_ img: StrKey) -> UIColor {
        return UIColor(named: img.key) ?? .clear
    }
    
    /// 색 채도를 더 밝게
    func lighter(_ amount:CGFloat = 0.25) -> UIColor {
        return hucolorWithBrightnessAmount(1 + amount)
    }
    /// 색 채도를 더 어둡게
    func darker(_ amount: CGFloat = 0.25) -> UIColor {
        return hucolorWithBrightnessAmount(1 - amount)
    }
    
    fileprivate func hucolorWithBrightnessAmount(_ amount: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var sat : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0
        
        if getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: sat, brightness: brightness * amount, alpha: alpha)
        } else {
            return self
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    convenience init(rgb: Int, _ alpha: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}
//MARK:- UIView Extension
public extension UIView {
    func setShadow(offset: CGSize = CGSize(width: 0, height: -1), color: UIColor = .black, opacity: Float = 0.4, radius: CGFloat = 8) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
    /**
     View의 부분적인 Corner Radius 적용
     
     - Parameters:
     - corners: 적용할 모서리 선택(ex:[.topLeft,.topRight])
     - radius: Radius 크기(ex:CGSize(width:10,height:10))
     */
    func partialCornerRadius(corners: UIRectCorner, radius: CGSize) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radius)
        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath

        self.layer.mask = maskLayer
    }
    
    func partialCornerRadius(corners: UIRectCorner, radius: CGFloat) {
        partialCornerRadius(corners: corners, radius: CGSize(width: radius, height: radius))
    }

    func partialBorderStroke(borderWidth: CGFloat = 2, borderColor: UIColor, corners: UIRectCorner, radius: CGFloat) {
        let borderLayer = getPartialBorderStroke(borderWidth: borderWidth, borderColor: borderColor, corners: corners, radius: radius)

        self.layer.addSublayer(borderLayer)
    }
    
    func getPartialBorderStroke(borderWidth: CGFloat = 2, borderColor: UIColor, corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let borderLayer = CAShapeLayer()

        borderLayer.path = path.cgPath

        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor

        return borderLayer
    }
    
    /// UIView를 이미지로
    @available(iOS 10.0, *)
    var toImage:UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    /// subview 모두 제거
    func removeAllSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }

    /// gesture 모두 제거
    func removeAllGestures() {
        for ges in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(ges)
        }
    }
}
//MARK:- UIApplication Extension
public extension UIApplication {
    /// topVC 반환 
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
//MARK:- UINavigationController Extension
public extension UINavigationController {
    /// pop VC with Completion
    func popViewController(_ animated: Bool = false, _ completion: @escaping ()->Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
    /// push VC with Completion
    func pushViewController(_ viewController: UIViewController, _ animated: Bool = false, _ completion: @escaping ()->Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

//MARK:- UIDevice Extension
public extension UIDevice {
    
    /// Notch 가 있는 단말인지 여부
    var hasNotch: Bool {
        guard #available(iOS 11.0, *) else { return false }
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
