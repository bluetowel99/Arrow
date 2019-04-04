
import UIKit

class MainTabController: UITabBarController {
    
    fileprivate let allTabItems = ARMainTabItem.allValues
    fileprivate var previousSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationItem.title = ""
        let imageView = UIImageView(image: R.image.arrowCompactLogo())
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        tabBarControllerSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = R.color.arrowColors.slateGray()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UINavigationBar.appearance().tintColor
    }
    
    // MARK: - UI Helpers
    
    private func tabBarControllerSetup() {
        var viewControllers = [UIViewController]()
        let _ = allTabItems.map {
            guard let viewController = $0.viewController else {
                assertionFailure("Tab item's view controller should not be nil.")
                return
            }
            viewController.tabBarItem.title = $0.title
            viewController.tabBarItem.image = $0.image
            viewController.tabBarItem.selectedImage = $0.selectedImage
            viewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            viewControllers.append(viewController)
        }
        self.viewControllers = viewControllers
    }
    
}

// MARK: - UITabBarControllerDelegate Implementation

extension MainTabController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        previousSelectedIndex = selectedIndex
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let selectedTabItem = allTabItems[selectedIndex]
        if selectedTabItem.isShownInTab == false,
            let controller = selectedTabItem.viewController as? DismissableUIViewController {
            controller.delegate = self
            let navController = UINavigationController(rootViewController: controller as! UIViewController)
            present(navController, animated: true, completion: nil)
            selectedIndex = previousSelectedIndex
        }
    }
    
}

// MARK: - Public Methods

extension MainTabController {
    
    func selectTab(tabItem: ARMainTabItem) {
        selectedIndex = Int(tabItem.rawValue)
    }
    
}

// MARK: - Dismissable Controller Delegate Implementation

extension MainTabController: DismissableControllerDelegate {
    
    func controllerDidDismiss(controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
