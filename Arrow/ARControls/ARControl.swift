
import UIKit

public class ARControl: UIControl {
    
    internal var kNib: UINib? { return nil }
    
    @IBOutlet weak var view: UIView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    fileprivate func nibSetup() {
        view = loadViewFromNib()
        addSubview(view)
        self.setViewConstraints(equalTo: view)
        viewDidLoad()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        guard let kNib = kNib else {
            assertionFailure("kNib must be set.")
            return UIView()
        }
        
        let view = kNib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    internal func viewDidLoad() {
        // To be overridden by subclasses.
    }
    
}
