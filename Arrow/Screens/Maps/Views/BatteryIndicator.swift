
import UIKit

@IBDesignable class BatteryIndicator: UIView {
    private var batteryPercentage: Double = 50 {
        didSet {
            updatePercentage()
        }
    }
    
    fileprivate let percentageLayer = CALayer()
    
    @IBInspectable var percentage: Double {
        set {
            if newValue < 0 {
                batteryPercentage = 10
            } else if newValue > 100 {
                batteryPercentage = 100
            } else {
                batteryPercentage = newValue
            }
        }
        get {
            return batteryPercentage
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        setupLayers()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 23, height: 12)
    }
}

private extension BatteryIndicator {
    func percentageRectangle() -> CGRect {
        let filledWidth = 18 * (percentage / 100)
        return CGRect(x: bounds.minX + 2, y: bounds.minY + 2, width: CGFloat(filledWidth), height: bounds.height - 4)
    }
    
    func setupLayers() {
        let batteryFrameLayer = CALayer()
        batteryFrameLayer.frame = bounds
        layer.contents = R.image.mapsMarkerInfoBattery()?.cgImage
        batteryFrameLayer.contentsGravity = kCAGravityResizeAspectFill
        layer.addSublayer(batteryFrameLayer)
        layer.addSublayer(percentageLayer)
        
        updatePercentage()
    }
    
    func updatePercentage() {
        percentageLayer.frame = percentageRectangle()
        percentageLayer.backgroundColor = fillColor()
    }
    
    func fillColor() -> CGColor {
        if percentage > 20 {
            return R.color.arrowColors.hathiGray().cgColor
        } else if percentage > 10 {
            return R.color.arrowColors.sunYellow().cgColor
        } else {
            return R.color.arrowColors.scarletRed().cgColor
        }
    }
}
