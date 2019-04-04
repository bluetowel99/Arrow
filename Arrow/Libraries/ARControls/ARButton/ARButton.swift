
import UIKit

@IBDesignable
public class ARButton: UIButton {
    
    fileprivate var activityIndicatorImageView: UIImageView!
    fileprivate var normalTitleColor: UIColor?
    
    @IBInspectable public var activityIndicatorImage: UIImage? = Appearance.activityIndicatorImage {
        didSet {
            activityIndicatorImageView.image = activityIndicatorImage
        }
    }
    
    @IBInspectable public var disabledBackgroundColor: UIColor = Appearance.disabledBackgroundColor  {
        didSet {
            updateButtonState()
        }
    }
    
    @IBInspectable public var enabledBackgroundColor: UIColor = Appearance.enabledBackgroundColor  {
        didSet {
            updateButtonState()
        }
    }
    
    @IBInspectable public var disabledBorderColor: UIColor = Appearance.disabledBorderColor  {
        didSet {
            updateButtonState()
        }
    }
    
    @IBInspectable public var enabledBorderColor: UIColor = Appearance.enabledBorderColor  {
        didSet {
            updateButtonState()
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = Appearance.borderWidth  {
        didSet {
            updateButtonState()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = Appearance.cornerRadius  {
        didSet {
            updateButtonState()
        }
    }
    
    fileprivate var _backgroundImageView: UIImageView?
    public var backgroundImageView: UIImageView? { return getBackgroundImageView() }
    
    public override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.updateButtonState()
            }
        }
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        viewSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewSetup()
    }
    
    private func viewSetup() {
        enabledBackgroundColor = backgroundColor ?? enabledBackgroundColor
        updateButtonState()
        updateActivityIndicatorImageView()
    }
    
    private func updateButtonState() {
        backgroundColor = isEnabled ? enabledBackgroundColor : disabledBackgroundColor
        layer.borderColor = isEnabled ? enabledBorderColor.cgColor : disabledBorderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    private func updateActivityIndicatorImageView() {
        activityIndicatorImageView = UIImageView()
        activityIndicatorImageView.contentMode = .center
        activityIndicatorImageView.image = activityIndicatorImage
        addSubview(activityIndicatorImageView)
        activityIndicatorImageView.isHidden = true
    }
    
    fileprivate func getBackgroundImageView() -> UIImageView? {
        if let cachedRef = _backgroundImageView {
            return cachedRef
        }
        
        for subview in subviews {
            if let imageView = subview as? UIImageView, imageView.image == currentBackgroundImage {
                _backgroundImageView = imageView
                return imageView
            }
        }
        
        return nil
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let imageViewFrame = CGRect(origin: CGPoint.zero, size: frame.size)
        activityIndicatorImageView.frame = imageViewFrame
    }
    
}

// MARK: - Activity Indicator

extension ARButton {
    
    public func showActivityIndicator() {
        // Hide button's title.
        normalTitleColor = titleColor(for: .normal)
        setTitleColor(.clear, for: .normal)
        // Disable interactions with the button.
        isUserInteractionEnabled = false
        // Show and animate activity indicator.
        activityIndicatorImageView.isHidden = false
        activityIndicatorImageView.startInfiniteRotationAnimation()
    }
    
    public func hideActivityIndicator() {
        // Show button's title.
        setTitleColor(normalTitleColor, for: .normal)
        // Enable interactions.
        isUserInteractionEnabled = true
        // Hide activity indicator.
        activityIndicatorImageView.isHidden = true
        activityIndicatorImageView.stopInfiniteRotationAnimation()
    }
    
}
