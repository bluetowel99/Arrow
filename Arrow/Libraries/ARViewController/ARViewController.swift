
import UIKit

/// UIViewController with Arrow-specific members and capabilities.

class ARViewController: UIViewController {
    
    enum NavigationBarTitleStyle {
        case compactLogo
        case fullLogo
        case none
    }
    
    var platform: ARPlatform = ARPlatform.shared
    var networkSession: ARNetworkSession? = ARNetworkSession.shared
    
    // NavigationBar Customization Properties
    var isNavigationBarBackTextHidden: Bool = false
    var navigationBarTitle: String? = nil
    var navigationBarTitleStyle: NavigationBarTitleStyle = .none {
        didSet {
            updateNavigationBarTitleStyle(navigationBarTitleStyle)
        }
    }
    
    // MARK: Status Bar Customization
    var isStatusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // Use Navigation Bar's first navigation item instead of Navigation Item.
    var useNavigationBarItem: Bool = false
    
    override var navigationItem: UINavigationItem {
        get {
            return useNavigationBarItem ? (navigationController?.navigationBar.items?.first)! : super.navigationItem
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBarTitleStyle(navigationBarTitleStyle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = navigationBarTitle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = isNavigationBarBackTextHidden ? "" : navigationItem.title
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
}

// MARK: - UI Helpers

extension ARViewController {
    
    fileprivate func updateNavigationBarTitleStyle(_ style: NavigationBarTitleStyle) {
        switch style {
        case .compactLogo:
            let imageView = UIImageView(image: R.image.arrowCompactLogo())
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        case .fullLogo:
            let imageView = UIImageView(image: R.image.arrowFullLogoNavBar())
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        case .none:
            navigationItem.titleView = nil
        }
    }
}

// MARK: - Event Handlers

extension ARViewController {
    
    @IBAction func navigationBackButtonPressed(_ sender: AnyObject) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - StoryboardViewController Extensions

extension StoryboardViewController where Self: ARViewController {
    
    static func instantiate(
        platform: ARPlatform = ARPlatform.shared,
        networkSession: ARNetworkSession? = ARNetworkSession.shared) -> Self {
        let instance = instantiate()
        instance.platform = platform
        instance.networkSession = networkSession
        return instance
    }
    
}

// MARK: - NibViewController Extensions

extension NibViewController where Self: ARViewController {
    
    static func instantiate(
        platform: ARPlatform = ARPlatform.shared,
        networkSession: ARNetworkSession? = ARNetworkSession.shared) -> Self {
        let instance = instantiate()
        instance.platform = platform
        instance.networkSession = networkSession
        return instance
    }
    
}
