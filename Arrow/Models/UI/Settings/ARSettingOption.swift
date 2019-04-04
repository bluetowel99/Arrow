
import UIKit

typealias ARSettingOptionAction = (ARSettingOptionType) -> Void

// MARK: - SettingOptionType Definition

enum ARSettingOptionType {
    
    case disclosure
    case switchOff
    case switchOn
    case none
    
}

// MARK: - SettingOption Definition

struct ARSettingOption {
    
    let title: String
    let type: ARSettingOptionType
    
}

// MARK: - SettingOptionType Icons

extension ARSettingOptionType {
    
    var icon: UIImage? {
        switch self {
        case .disclosure:
            return R.image.settingOptionDisclose()
        case .switchOff:
            return R.image.settingOptionSwitchOff()
        case .switchOn:
            return R.image.settingOptionSwitchOn()
        case .none:
            return nil
        }
    }
    
    func toggled() -> ARSettingOptionType {
        switch self {
        case .switchOff:
            return .switchOn
        case .switchOn:
            return .switchOff
        default:
            return self
        }
    }
    
}

// MARK: - ARSettingOption Helper Methods

extension ARSettingOption {
    
    func with(type: ARSettingOptionType) -> ARSettingOption {
        return ARSettingOption(title: title, type: type)
    }
    
}
