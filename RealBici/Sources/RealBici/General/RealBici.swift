import Foundation
import UIKit


public class RealBici {

    public class var shared: RealBici {
        struct Static {
            static let instance: RealBici = RealBici()
        }
        return Static.instance
    }

    private init() {}
    
    var loadingScreen: UIView?
    var window:UIWindow?
    /**
     노치 모델인 경우
     */
    public func isNotch() -> Bool {
        return UIScreen.main.bounds.size.height >= 812
    }
    
    
    /// 외부링크(다른 앱 or Safari)
    /// - Parameters:
    ///   - link: your link String(URLScheme or web)
    ///   - completion: completion
    @available(iOS 10.0, *)
    public func linkExternal(_ link: String, _ completion:((Bool) -> Void)? = nil) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, completionHandler: completion)
    }
    
    
    // MARK: - Alert Controller

    public func alert(vc: UIViewController? = UIApplication.topViewController(), _ msg: String, _ title: String = "알림", isTwoBtn: Bool = false, confirmTitle:String = "확인", cancelTitle:String = "취소", cancelcomp:(()->Void)? = nil, completion:(()->Void)? = nil) {
        if Thread.isMainThread {
            presentAlert(vc: vc, msg, title, isTwoBtn: isTwoBtn, confirmTitle: confirmTitle, cancelTitle: cancelTitle, cancelcomp: cancelcomp, completion: completion)
        } else {
            DispatchQueue.main.async { [unowned self] in
                self.presentAlert(vc: vc, msg, title, isTwoBtn: isTwoBtn, confirmTitle: confirmTitle, cancelTitle: cancelTitle, cancelcomp: cancelcomp, completion: completion)
            }
        }
    }

    func presentAlert(vc: UIViewController? = UIApplication.topViewController(), _ msg: String, _ title: String = "알림", isTwoBtn: Bool = false, confirmTitle:String = "확인", cancelTitle:String = "취소", cancelcomp:(()->Void)? = nil, completion:(()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: confirmTitle, style: .default) { _ in
            completion?()
        }

        alert.addAction(action)

        if isTwoBtn {
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                cancelcomp?()
            }
            alert.addAction(cancel)
        }

        vc?.present(alert, animated: false, completion: nil)
    }
    
    // MARK: - Loading Screen
    public func showLoading() {
        if Thread.isMainThread {
            createLoading()
        } else {
            DispatchQueue.main.async {
                RealBici.shared.createLoading()
            }
        }
    }
    
    public func initLoading(_ window:UIWindow?,_ subviews:[UIView]) {
        let screen = UIScreen.main.bounds
        loadingScreen = UIView()
        loadingScreen?.frame = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)
        loadingScreen?.backgroundColor = .clear //UIColor(rgb: 0x000000, 0.4)
        self.window = window
        
        for vw in subviews {
            loadingScreen?.addSubview(vw)
        }
    }

    func createLoading() {
        hideLoading()
        
        guard let loadingVw = loadingScreen else { return }

        window?.addSubview(loadingVw)
    }

    public func hideLoading() {
        if Thread.isMainThread {
            removeLoading()
        } else {
            DispatchQueue.main.async {
                RealBici.shared.removeLoading()
            }
        }
    }

    func removeLoading() {
        guard let _ = loadingScreen else { return }

        loadingScreen?.removeFromSuperview()
        loadingScreen = nil
    }

}
