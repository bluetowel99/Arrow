
import UIKit

final class NotificationSettingsController: SettingPageController {
    
    typealias T = NotificationSettingsPageOptions
    static var model: ARSettingPage = NotificationSettingsPage()
    
    var platform: ARPlatform!
    var networkSession: ARNetworkSession!
    var options = model.options
    var refreshCallback: (([ARSettingOption]) -> Void)?
    
    func refresh() {
        if let dealsEnabled = platform.userSettings.dealsNotification {
            updateOptions(for: T.dealsNearMe, withType: dealsEnabled ? .switchOn : .switchOff)
        }
        
        refreshCallback?(options)
    }
    
    func settingPageDidSelect(controller: SettingPageVC, optionIndex: UInt) {
        guard let option = T(rawValue: optionIndex) else {
            print("Selected index does not map to a valid page option.")
            return
        }
        
        switch option {
        case .activityFeedPost:
            navigateToSettingPage(pageController: ActivityFeedSettingsController(), from: controller)
        case .dealsNearMe:
            dealsNearMeSwitchTapped(option: options[Int(optionIndex)])
            break
        case .litMeterRating:
            navigateToSettingPage(pageController: LitSettingsController(), from: controller)
        case .placeRating:
            navigateToSettingPage(pageController: RatePlaceSettingsController(), from: controller)
        }
    }
    
}

// MARK: - Logic Helper Methods

extension NotificationSettingsController {
    
    fileprivate func dealsNearMeSwitchTapped(option: ARSettingOption) {
        let newType = option.type.toggled()
        updateOptions(for: T.dealsNearMe, withType: newType)
        refreshCallback?(options)
        
        let settings = ARSettings(dealsNotification: newType == .switchOn)
        updateMySettings(settings) { error in
            if let error = error {
                print("Update settings error: \(error.localizedDescription)")
                return
            }
            
            self.platform.userSettings.dealsNotification = settings.dealsNotification
        }
    }
    
}
