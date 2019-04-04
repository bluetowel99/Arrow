
import Foundation

struct RatePlaceSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Rated a Place"
    var menuTitle: String = "RECEIVE NOTIFICATIONS FROM"
    var options: [ARSettingOption] = RatePlaceSettingsPageOptions.allValues.map { $0.option }
    
}

enum RatePlaceSettingsPageOptions: UInt {
    
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
