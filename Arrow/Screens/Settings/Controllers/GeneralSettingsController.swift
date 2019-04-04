
import UIKit

final class GeneralSettingsController: SettingPageController {
    
    static var model: ARSettingPage = GeneralSettingsPage()
    
    var platform: ARPlatform!
    var networkSession: ARNetworkSession!
    var options = model.options
    var refreshCallback: (([ARSettingOption]) -> Void)?
    
    func refresh() {
        refreshCallback?(options)
        
        // Load user's settings from the backend.
        fetchMySettings { settings, error in
            if let error = error {
                print("Error fetching My Profile: \(error.localizedDescription)")
                return
            }
            
            if let settings = settings {
                self.platform.userSettings = settings
            }
        }
    }
    
    func settingPageDidSelect(controller: SettingPageVC, optionIndex: UInt) {
        guard let option = GeneralSettingsPageOptions(rawValue: optionIndex) else {
            print("Selected index does not map to a valid page option.")
            return
        }
        
        switch option {
        case .help:
            let helpVC = HelpVC.instantiate()
            controller.navigationController?.pushViewController(helpVC, animated: true)
        case .myInfo:
            let editProfileVC = EditProfileVC.instantiate()
            controller.navigationController?.pushViewController(editProfileVC, animated: true)
        case .notifications:
            navigateToSettingPage(pageController: NotificationSettingsController(), from: controller)
        case .permissions:
            navigateToSettingPage(pageController: PermissionSettingsController(), from: controller)
        case .privacy:
            navigateToSettingPage(pageController: PrivacySettingsController(), from: controller)
        case .signOut:
            performUserSignOut(platform: controller.platform)
        }
    }
    
}

// MARK: - Event Handlers

extension GeneralSettingsController {
    
    fileprivate func performUserSignOut(platform: ARPlatform) {
        platform.userSession = nil
        platform.requestRootViewControllerUpdate(switchingToLoggedInMode: false)
    }
    
}

// MARK: - Networking

extension GeneralSettingsController {
    
    fileprivate func fetchMySettings(callback: ((ARSettings?, NSError?) -> Void)?) {
        let getMySettingsReq = GetMySettingsRequest()
        let _ = networkSession?.send(getMySettingsReq) { result in
            switch result {
            case .success(let settings):
                callback?(settings, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}
