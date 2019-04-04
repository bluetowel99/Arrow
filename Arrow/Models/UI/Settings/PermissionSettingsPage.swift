
import Foundation

struct PermissionSettingsPage: ARSettingPage {
    
    var navigationBarTitle: String = "Permissions"
    var menuTitle: String = " "
    var options: [ARSettingOption] = PermissionSettingsPageOptions.allValues.map { $0.option }
    
}

enum PermissionSettingsPageOptions: UInt {
    
    case location = 0
    case contatcs
    case cameraAndMic
    case photos
    
    var option: ARSettingOption {
        switch self {
        case .cameraAndMic:
            return ARSettingOption(title: "Allow Access to Camera & Mic", type: .switchOff)
        case .contatcs:
            return ARSettingOption(title: "Allow Access to Your Contacts", type: .switchOff)
        case .location:
            return ARSettingOption(title: "Share Your Location", type: .switchOff)
        case .photos:
            return ARSettingOption(title: "Allow Access to Photos", type: .switchOff)
        }
    }
    
}
