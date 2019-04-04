
import UIKit

// MARK: - Rotation Animation Extensions

extension CALayer {
    
    func addInfiniteRotationAnimation(clockwise: Bool = true) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi * (clockwise ? 1 : -1)
        rotation.duration = 0.7
        rotation.repeatCount = Float.infinity
        removeAllAnimations()
        add(rotation, forKey: "Spin")
    }
    
    func removeInfiniteRotationAnimation() {
        removeAnimation(forKey: "Spin")
    }
    
}

// MARK: - Interface Builder Extensions

extension CALayer {
    
    @IBInspectable public var shadowUIColor: UIColor {
        set (color) {
            shadowColor = color.cgColor
        }
        get {
            return UIColor(cgColor: shadowColor ?? UIColor.clear.cgColor)
        }
    }
    
}
