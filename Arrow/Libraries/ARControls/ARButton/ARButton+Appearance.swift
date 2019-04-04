
import UIKit

extension ARButton {
    
    public struct Appearance {
        public static var disabledBackgroundColor: UIColor = .clear
        public static var enabledBackgroundColor: UIColor = R.color.arrowColors.waterBlue()
        public static var disabledBorderColor: UIColor = R.color.arrowColors.silver()
        public static var enabledBorderColor: UIColor = R.color.arrowColors.waterBlue()
        public static var borderWidth: CGFloat = 1.0
        public static var cornerRadius: CGFloat = 3.0
        public static var activityIndicatorImage: UIImage? = R.image.circularActivityIndicator()
    }
    
}
