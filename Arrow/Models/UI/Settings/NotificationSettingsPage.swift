
import Foundation

struct NotificationSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Notifications"
    var menuTitle: String = "General"
    var options: [ARSettingOption] = NotificationSettingsPageOptions.allValues.map { $0.option }
    
}

enum NotificationSettingsPageOptions: UInt {
    
    case dealsNearMe = 0
    case litMeterRating
    case placeRating
    case activityFeedPost
    
    var option: ARSettingOption {
        switch self {
        case .activityFeedPost:
            return ARSettingOption(title: "Posted to Activity Feed", type: .disclosure)
        case .dealsNearMe:
            return ARSettingOption(title: "Receive Deals Near Me", type: .switchOff)
        case .litMeterRating:
            return ARSettingOption(title: "Rated Lit Meter", type: .disclosure)
        case .placeRating:
            return ARSettingOption(title: "Rated a Place", type: .disclosure)
        }
    }
    
}
