
import UIKit

final class ActivityFeedSettingsController: SettingPageController {
    
    typealias T = ActivityFeedSettingsPageOptions
    static var model: ARSettingPage = ActivityFeedSettingsPage()
    
    var platform: ARPlatform!
    var networkSession: ARNetworkSession!
    var options = model.options
    var refreshCallback: (([ARSettingOption]) -> Void)?
    
    func refresh() {
        switch platform.userSettings.activityFeedNotification {
        case .some(.arrowFriends):
            updateOptions(for: T.arrowFriends, withType: .switchOn)
            updateOptions(for: T.bubbleMembers, withType: .switchOff)
        case .some(.bubbleMembers):
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOn)
        case .some(.everyone):
            assertionFailure("Unsupported Activity Feed settings option.")
        case .none:
            break
        }
        
        refreshCallback?(options)
    }
    
    func settingPageDidSelect(controller: SettingPageVC, optionIndex: UInt) {
        guard let option = T(rawValue: optionIndex) else {
            print("Selected index does not map to a valid page option.")
            return
        }
        
        var choice = ARSettingVisibility.arrowFriends
        switch option {
        case .arrowFriends:
            updateOptions(for: T.arrowFriends, withType: .switchOn)
            updateOptions(for: T.bubbleMembers, withType: .switchOff)
            choice = .arrowFriends
        case .bubbleMembers:
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOn)
            choice = .bubbleMembers
        }
        
        refreshCallback?(options)
        
        // Make the API call.
        let settings = ARSettings(activityFeedNotification: choice)
        updateMySettings(settings) { error in
            if let error = error {
                print("Error updating settings: \(error.localizedDescription)")
                return
            }
            
            self.platform.userSettings.activityFeedNotification = settings.activityFeedNotification
        }
    }
    
}