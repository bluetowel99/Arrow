
import UIKit

final class PrivacySettingsController: SettingPageController {
    
    typealias T = PrivacySettingsPageOptions
    static var model: ARSettingPage = PrivacySettingsPage()
    
    var platform: ARPlatform!
    var networkSession: ARNetworkSession!
    var options = model.options
    var refreshCallback: (([ARSettingOption]) -> Void)?
    
    func refresh() {
        switch platform.userSettings.profileVisibility {
        case .some(.arrowFriends):
            updateOptions(for: T.arrowFriends, withType: .switchOn)
            updateOptions(for: T.bubbleMembers, withType: .switchOff)
            updateOptions(for: T.everyone, withType: .switchOff)
        case .some(.bubbleMembers):
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOn)
            updateOptions(for: T.everyone, withType: .switchOff)
        case .some(.everyone):
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOff)
            updateOptions(for: T.everyone, withType: .switchOn)
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
            updateOptions(for: T.everyone, withType: .switchOff)
            choice = .arrowFriends
        case .bubbleMembers:
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOn)
            updateOptions(for: T.everyone, withType: .switchOff)
            choice = .bubbleMembers
        case .everyone:
            updateOptions(for: T.arrowFriends, withType: .switchOff)
            updateOptions(for: T.bubbleMembers, withType: .switchOff)
            updateOptions(for: T.everyone, withType: .switchOn)
            choice = .everyone
        }
        
        refreshCallback?(options)
        
        // Make the API call.
        let settings = ARSettings(profileVisibility: choice)
        updateMySettings(settings) { error in
            if let error = error {
                print("Error updating settings: \(error.localizedDescription)")
                return
            }
            
            self.platform.userSettings.profileVisibility = settings.profileVisibility
        }
    }
    
}
