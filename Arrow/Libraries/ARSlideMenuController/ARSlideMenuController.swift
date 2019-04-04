
import UIKit
import QuartzCore

enum ARSlideMenuState {
    case bothCollapsed
    case leftPanelExpanded
    case rightPanelExpanded
}

/// Slide Menu Controller

class ARSlideMenuController: UIViewController {
    
    fileprivate var leftViewController: ARSlideMenuSideViewController?
    fileprivate var rightViewController: ARSlideMenuSideViewController?
    
    public var centerPanelExpandedOffset: CGFloat = UIScreen.main.bounds.width * 0.30
    
    public var currentState: ARSlideMenuState = .bothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .bothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    fileprivate var navController: ARSlideMenuNavigationController!
    fileprivate var shadowOverlay: UIView!
    
    public init (centerViewController: UIViewController, leftViewController: ARSlideMenuSideViewController? = nil, rightViewController: ARSlideMenuSideViewController? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        navController = ARSlideMenuNavigationController(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
        navController.viewControllers = [centerViewController]
        navController.slideMenuDelegate = self
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
        
        shadowOverlay = UIView(frame: navController.view.frame)
        shadowOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(shadowOverlayTapped(_:)))
        tapGesture.delegate = self
        shadowOverlay.addGestureRecognizer(tapGesture)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if navController == nil {
            assertionFailure("NavController must have been set.")
        }
        
        view.addSubview(navController.view)
        addChildViewController(navController)
        
        navController.didMove(toParentViewController: self)
        
        // let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        // navController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
}

// MARK: - Public Methods

extension ARSlideMenuController {
    
    public func addLeftBarButtonWithImage(image: UIImage?) {
        addNavigationBarButton(image: image, leftSide: true)
    }
    
    public func addRightBarButtonWithImage(image: UIImage?) {
        addNavigationBarButton(image: image, leftSide: false)
    }
    
    private func addNavigationBarButton(image: UIImage?, leftSide: Bool) {
        let eventHandler: Selector = leftSide ? #selector(leftBarButtonPressed(_:)) : #selector(rightBarButtonPressed(_:))
        let barButton = UIBarButtonItem(image: image, style: .plain, target: self, action: eventHandler)
        navController.viewControllers.first?.navigationItem.leftBarButtonItem = barButton
    }
    
}

// MARK: - Event Handlers

extension ARSlideMenuController {
    
    @objc func leftBarButtonPressed(_ sender: AnyObject) {
        slideMenuToggleLeftPanel()
    }
    
    @objc func rightBarButtonPressed(_ sender: AnyObject) {
        slideMenuToggleRightPanel()
    }
    
    @objc func shadowOverlayTapped(_ sender: AnyObject) {
        // TODO(kia): Should change the logic to support left/right menus.
        leftBarButtonPressed(sender)
    }
    
}

// MARK: ARSlideMenuControllerDelegate Implementation

extension ARSlideMenuController: ARSlideMenuNavigationControllerDelegate {
    
    func slideMenuToggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        shadowOverlay.removeFromSuperview()
        if notAlreadyExpanded {
            addLeftPanelViewController()
            navController.view.addSubview(shadowOverlay)
        }
        
        // Animate shadow overlay in/out.
        shadowOverlay.layer.opacity = notAlreadyExpanded ? 0.0 : 1.0
        UIView.animate(withDuration: 0.15) {
            self.shadowOverlay.layer.opacity = notAlreadyExpanded ? 1.0 : 0.0
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func slideMenuToggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
        
        if notAlreadyExpanded {
            addRightPanelViewController()
        }
        
        animateRightPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func slideMenuCollapseSidePanels() {
        switch (currentState) {
        case .rightPanelExpanded:
            slideMenuToggleRightPanel()
        case .leftPanelExpanded:
            slideMenuToggleLeftPanel()
        case .bothCollapsed:
            break
        }
    }
    
    func addLeftPanelViewController() {
        guard let leftViewController = leftViewController else {
            return
        }
        addChildSidePanelController(leftViewController)
    }
    
    func addChildSidePanelController(_ sidePanelController: ARSlideMenuSideViewController) {
        sidePanelController.delegate = navController
        
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMove(toParentViewController: self)
    }
    
    func addRightPanelViewController() {
        guard let rightViewController = rightViewController else {
            return
        }
        addChildSidePanelController(rightViewController)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .leftPanelExpanded
            
            animateCenterPanelXPosition(to: navController.view.frame.width - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(to: 0) { finished in
                self.currentState = .bothCollapsed
                
                self.leftViewController?.view.removeFromSuperview()
            }
        }
    }
    
    func animateCenterPanelXPosition(to targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.navController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .rightPanelExpanded
            
            animateCenterPanelXPosition(to: -navController.view.frame.width + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(to: 0) { _ in
                self.currentState = .bothCollapsed
                
                self.rightViewController?.view.removeFromSuperview()
            }
        }
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        navController.view.layer.shadowRadius = 15.0
        if (shouldShowShadow) {
            navController.view.layer.shadowOpacity = 0.07
        } else {
            navController.view.layer.shadowOpacity = 0.0
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate Implementation

extension ARSlideMenuController: UIGestureRecognizerDelegate {
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        
        switch(recognizer.state) {
        case .began:
            if (currentState == .bothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                } else {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .changed:
            if gestureIsDraggingFromLeftToRight && leftViewController == nil {
                return
            }
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
            recognizer.setTranslation(CGPoint.zero, in: view)
        case .ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            } else if (rightViewController != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
}
