
import Foundation

struct PrivacySettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Privacy"
    var menuTitle: String = "WHO CAN SEE MY PROFILE"
    var options: [ARSettingOption] = PrivacySettingsPageOptions.allValues.map { $0.option }
    
}

enum PrivacySettingsPageOptions: UInt {
    
    case arrowFriends = 0
    case bubbleMembers
    case everyone
    
    var option: ARSettingOption {
        switch self {
        case .arrowFriends:
            return ARSettingOption(title: "Arrow Friends", type: .switchOff)
        case .bubbleMembers:
            return ARSettingOption(title: "Bubble Members", type: .switchOff)
        case .everyone:
            return ARSettingOption(title: "Everyone", type: .switchOff)
        }
    }
    
}
