
import UIKit

final class MapsBubbleBar: ARControl {
    
    override var kNib: UINib? { return R.nib.mapsBubbleBar() }
    
    @IBOutlet var borderLines: [UIView]!
    @IBOutlet weak var thumbnailButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    
    var delegate: MapsBubbleBarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateView(with: nil)
    }
    
}

// MARK: - UI Helpers

extension MapsBubbleBar {
    
    fileprivate func updateView(with bubble: ARBubble?) {
        var bgColor = R.color.arrowColors.waterBlue()
        var titleColor = UIColor.white
        var arrowColor = UIColor.white
        var borderColor = UIColor.white
        
        if let bubble = bubble {
            // - Mode 1: Display active bubble info.
            
            bgColor = R.color.arrowColors.paleGray()
            titleColor = R.color.arrowColors.ironGray()
            arrowColor = R.color.arrowColors.slateGray()
            borderColor = R.color.arrowColors.silver()
            titleButton.setTitle(bubble.title, for: .normal)
            if let url = bubble.pictureUrl {
                UIImage.load(from: url) { image in
                    self.thumbnailButton.setImage(image, for: .normal)
                    self.thumbnailButton.backgroundColor = .white
                }
            }
            
        } else {
            // - Mode 2: Create new bubble.
            
            bgColor = R.color.arrowColors.waterBlue()
            titleColor = .white
            arrowColor = .white
            borderColor = .white
            titleButton.setTitle("Create Your First Bubble", for: .normal)
            thumbnailButton.setImage(nil, for: .normal)
            thumbnailButton.backgroundColor = .clear
        }
        
        titleButton.isEnabled = true
        thumbnailButton.isEnabled = true
        iconButton.isEnabled = true
        arrowButton.isEnabled = true
        
        // Update colors.
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = bgColor
            self.titleButton.setTitleColor(titleColor, for: .normal)
            self.arrowButton.tintColor = arrowColor
            let _ = self.borderLines.map { $0.backgroundColor = borderColor }
        })
        
        // Update left-hand side button's icon/thumbnail.
        let isThumbnailHidden = bubble == nil
        thumbnailButton.isHidden = isThumbnailHidden
        iconButton.isHidden = !isThumbnailHidden
        
    }
    
}

// MARK: - Public Methods

extension MapsBubbleBar {
    
    func refresh(using bubbleStore: ARBubbleStore?) {
        updateView(with: bubbleStore?.activeBubble)
    }
    
    func turnArrow(up: Bool, animated: Bool) {
        let animationDuration: Double = animated ? 0.2 : 0.0
        let angle: CGFloat = up ? .pi : .pi * 2
        let transform = CGAffineTransform(rotationAngle: angle)
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.arrowButton.transform = transform
        })
    }
    
}

// MARK: - Event Handlers

extension MapsBubbleBar {
    
    @IBAction func arrowButtonPressed(sender: AnyObject) {
        delegate?.mapsBubbleBarDidPressArrowButton(controller: self)
    }
    
    @IBAction func mainButtonPresse(sender: AnyObject) {
        delegate?.mapsBubbleBarDidPressMainButton(controller: self)
    }
    
}

// MARK: - MapsBubbleBarDelegate Definition

protocol MapsBubbleBarDelegate {
    func mapsBubbleBarDidPressArrowButton(controller: MapsBubbleBar)
    func mapsBubbleBarDidPressMainButton(controller: MapsBubbleBar)
}
