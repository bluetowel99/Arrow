
import Foundation

struct ActivityFeedSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Posted to Activity Feed"
    var menuTitle: String = "RECEIVE NOTIFICATIONS FROM"
    var options: [ARSettingOption] = ActivityFeedSettingsPageOptions.allValues.map { $0.option }
    
}

enum ActivityFeedSettingsPageOptions: UInt {
    
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
