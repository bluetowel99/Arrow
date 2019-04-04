
import UIKit

final class ARDrawer: UIViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.aRDrawer()
    static var kStoryboardIdentifier: String? = "ARDrawer"
    
    weak var sourceViewController: UIViewController?
	var contentViewController: ARDrawerContentViewController? {
		didSet {
            contentViewController?.drawer = self
			if isViewLoaded {
				setupChild()
			}
		}
	}
    @IBOutlet weak var topView: UIView!
	@IBOutlet weak var dragView: UIStackView!
	@IBOutlet weak var contentContainer: UIView!
	var completionHandler: (()->Void?)?
    
	fileprivate var presentationManager = ARDrawerPresentationManager()
	
	override var modalPresentationStyle: UIModalPresentationStyle {
		set {}
		get {
			return .custom
		}
	}
	
	override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
		set {}
		get {
			return presentationManager
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

        presentationManager.setupInteractionControllerForDismissal(with: self)
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTopView(_: ))))
		setupChild()
	}
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let sourceVC = sourceViewController else { return }
        sourceVC.becomeFirstResponder()
    }
	func setupChild() {
		guard let childViewController = contentViewController,
			let contentView = childViewController.view else { return }
		
		contentView.translatesAutoresizingMaskIntoConstraints = false
		addChildViewController(childViewController)
		contentView.bounds = contentContainer.bounds
		contentContainer.addSubview(contentView)
		
		contentView.topAnchor.constraint(equalTo: contentContainer.topAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor).isActive = true
		contentView.leftAnchor.constraint(equalTo: contentContainer.leftAnchor).isActive = true
		contentView.rightAnchor.constraint(equalTo: contentContainer.rightAnchor).isActive = true
		
		childViewController.didMove(toParentViewController: self)
	}
    
    func dismiss(with interaction: Bool) {
        guard let presentingVC = presentingViewController else { return }
        presentationManager.interactiveDismiss = interaction
        
        presentingVC.dismiss(animated: true) {
            guard let completion = self.completionHandler else { return }
            completion()
        }
    }

    @objc func didTapTopView(_ sender: AnyObject) {
        self.dismiss(with: false)
    }
}
