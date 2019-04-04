
import UIKit

@IBDesignable class ARDividerView: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 1.0 / UIScreen.main.scale)
    }
    
    override func contentCompressionResistancePriority(for axis: UILayoutConstraintAxis) -> UILayoutPriority {
        switch axis {
        case .horizontal: return super.contentCompressionResistancePriority(for: axis)
        case .vertical: return UILayoutPriority.required
        }
    }
}

