
/// AppDelegateHelpers contains a collection of Arrow-specific helper methods for AppDelegate.

import UIKit
import SVProgressHUD

// MARK: - App Initialization & Window Setup

extension AppDelegate {
    
    func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        ARThemeManager.install(theme: .brandIdentity)
        
        ARPlatform.shared.delegate = self
        
        updateRootViewController()
        window?.makeKeyAndVisible()
    }
    
    fileprivate func updateRootViewController() {
        window?.rootViewController = getRootViewController()
    }
    
    /// Returns app's root view controller based on certain criteria.
    
    fileprivate func getRootViewController() -> UIViewController {
        switch ARPlatform.shared.sessionMode {
        case .anonymouslyLoggedIn, .loggedIn:
            return getMainTabController()
        case .loggedOut:
            return getOnboardingController()
        }
    }
    
    fileprivate func getOnboardingController() -> UIViewController {
        let onboardingVC = OnboardingVC.instantiate()
        return UINavigationController(rootViewController: onboardingVC)
    }
    
    fileprivate func getMainTabController() -> UIViewController {
        ARPlatform.mainTabController = MainTabController()
        ARPlatform.mainTabController?.selectTab(tabItem: .map)
        return UINavigationController(rootViewController: ARPlatform.mainTabController!)
    }

    /// Configure SVProgressHUD views
    func configureProgressView() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setDefaultAnimationType(.flat)

        SVProgressHUD.setInfoImage(#imageLiteral(resourceName: "InfoIcon"))

        SVProgressHUD.setErrorImage(#imageLiteral(resourceName: "WarningIcon"))
        SVProgressHUD.setImageViewSize(CGSize(width: 81, height: 37))
        SVProgressHUD.setMaximumDismissTimeInterval(1.5)
    }
    
}

// MARK: - ARPlatformDelegate Implementation

extension AppDelegate: ARPlatformDelegate {
    
    func platformDidRequestUpdatingRootViewController(platform: ARPlatform) {
        updateRootViewController()
    }
    
}
