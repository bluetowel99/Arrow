
import Foundation

struct GeneralSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Settings"
    var menuTitle: String = "General"
    var options: [ARSettingOption] = GeneralSettingsPageOptions.allValues.map { $0.option }
    
}

enum GeneralSettingsPageOptions: UInt {
    
    case myInfo = 0
    case permissions
    case notifications
    case privacy
    case help
    case signOut
    
    var option: ARSettingOption {
        switch self {
        case .permissions:
            return ARSettingOption(title: "Permissions", type: .disclosure)
        case .help:
            return ARSettingOption(title: "Help", type: .disclosure)
        case .myInfo:
            return ARSettingOption(title: "My Info", type: .disclosure)
        case .notifications:
            return ARSettingOption(title: "Notifications", type: .disclosure)
      
        case .privacy:
            return ARSettingOption(title: "Privacy", type: .disclosure)
        case .signOut:
            return ARSettingOption(title: "Sign Out", type: .none)
        }
    }
    
}
