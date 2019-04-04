
import UIKit

final class MapsBubblesVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.mapsBubbles()
    static var kStoryboardIdentifier: String? = "MapsBubblesVC"
    
    @IBOutlet weak var blurredBackgroundView: UIView!
    @IBOutlet weak var bubblesListHolderView: UIView!
    
    fileprivate var bubblesListVC: BubblesListVC?
    
    var bubbleStore: ARBubbleStore?
    var listDelegate: BubblesListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBubblesList()
    }
    
}

// MARK: - UI Helpers

extension MapsBubblesVC {
    
    fileprivate func setupView() {
        setupBackgroundBlur()
    }
    
    fileprivate func setupBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredBackgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredBackgroundView.addSubview(blurEffectView)
    }
    
    fileprivate func setupBubblesList() {
        let bubblesListVC = BubblesListVC.instantiate()
        self.bubblesListVC = bubblesListVC
        bubblesListVC.bubbleStore = bubbleStore
        bubbleStore?.bubblesListVC = self.bubblesListVC
        bubblesListVC.delegate = listDelegate
        self.addChildViewController(childController: bubblesListVC, on: bubblesListHolderView)
    }
    
}

// MARK: - Public Methods

extension MapsBubblesVC {
    
    func hideBubblesList(_ hide: Bool, animated: Bool) { }
    
    func refreshBubbleData() {
        bubblesListVC?.reloadBubbleData()
    }
    
}
