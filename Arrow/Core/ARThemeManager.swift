
import UIKit

class ARThemeManager {
    
    enum ARTheme {
        case brandIdentity
    }
    
    static func install(theme: ARTheme) {
        switch theme {
        case .brandIdentity:
            UIBarButtonItemThemes.applyBrandIdentity()
            UINavigationBarThemes.applyBrandIdentity()
            UITabBarThemes.applyBrandIdentity()
        }
    }
    
}

// MARK: - UIBarButtonItem

extension ARThemeManager {
    
    struct UIBarButtonItemThemes {
        
        static func applyBrandIdentity() {
            let titleFont = R.font.alegreyaSansExtraBold(size: 16.0)!
            setBarButtonFont(titleFont, fontColor: R.color.arrowColors.hathiGray(), for: .normal)
            setBarButtonFont(titleFont, fontColor: R.color.arrowColors.hathiGray().withAlphaComponent(0.4), for: .disabled)
        }
        
        private static func setBarButtonFont(_ font: UIFont, fontColor: UIColor, for state: UIControlState) {
            let attributes = [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: fontColor
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: state)
        }
        
    }
    
}

// MARK: - UINavigationBar

extension ARThemeManager {
    
    struct UINavigationBarThemes {
        
        static func applyBrandIdentity() {
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().barTintColor = .white
            UINavigationBar.appearance().tintColor = R.color.arrowColors.hathiGray()
            let titleFont = R.font.alegreyaSansExtraBold(size: 22.0)!
            setNavigationFont(titleFont, fontColor: R.color.arrowColors.onyxGray())
            
            // Remove navigation bar's bottom separator line.
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            
            // Replace back indicator's image.
            let backArrowImage = R.image.navigationBackArrow()?.withRenderingMode(.alwaysOriginal)
            UINavigationBar.appearance().backIndicatorImage = backArrowImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backArrowImage
        }
        
        private static func setNavigationFont(_ font: UIFont, fontColor: UIColor) {
            let attributes = [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: fontColor
            ]
            UINavigationBar.appearance().titleTextAttributes = attributes
        }
        
    }
    
}

// MARK: - UITabBar

extension ARThemeManager {
    
    struct UITabBarThemes {
        
        static func applyBrandIdentity() {
            UITabBar.appearance().isTranslucent = true
            UITabBar.appearance().barTintColor = R.color.arrowColors.vanillaWhite()
            UITabBar.appearance().tintColor = R.color.arrowColors.waterBlue()
            let titleFont = R.font.alegreyaSansMedium(size: 10.0)!
            setTabBarFont(titleFont)
        }
        
        private static func setTabBarFont(_ font: UIFont) {
            let attributes = [
                NSAttributedStringKey.font: font
            ]
            UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        }
        
    }
    
}
