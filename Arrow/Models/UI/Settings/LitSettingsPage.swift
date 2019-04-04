
import Foundation

struct LitSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Rated Lit Meter"
    var menuTitle: String = "RECEIVE NOTIFICATIONS FROM"
    var options: [ARSettingOption] = LitSettingsPageOptions.allValues.map { $0.option }
    
}

enum LitSettingsPageOptions: UInt {
    
    case arrowFriends = 0
    case bubbleMembers
    
    var option: ARSettingOption {
        switch self {
        case .arrowFriends:
            return ARSettingOption(title: "Arrow Friends", type: .switchOff)
        case .bubbleMembers:
            return ARSettingOption(title: "Bubble Members", type: .switchOff)
        }
    }
    
}
