
import UIKit

final class OnboardingVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.onboarding()
    static var kStoryboardIdentifier: String? = "OnboardingVC"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    fileprivate let promoImages: [UIImage?] = [
        R.image.promoBubbles(),
        R.image.promoPOIs(),
        R.image.promoEvents(),
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = ""
        setupView()
        setLocalizableStrings()
        setupScrollingSlides(scrollView: scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollingSlidesLayout(scrollView: scrollView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// MARK: - UI Helpers

extension OnboardingVC {
    
    fileprivate func setupView() {
        pageControl.pageIndicatorTintColor = R.color.arrowColors.waterBlue().withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = R.color.arrowColors.waterBlue()
        pageControl.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        pageControl.isUserInteractionEnabled = false

        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 5
        signupButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
        signupButton.setTitleColor(R.color.arrowColors.waterBlue(), for: .normal)

        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 5
        loginButton.layer.borderColor = R.color.arrowColors.oceanBlue().cgColor
        loginButton.setTitleColor(R.color.arrowColors.oceanBlue(), for: .normal)
    }
    
    fileprivate func setLocalizableStrings() {
        signupButton.setTitle(R.string.onboarding.onboardingSignupButtonTitle(), for: .normal)
        loginButton.setTitle(R.string.onboarding.onboardingLoginButtonTitle(), for: .normal)
    }
    
}

// MARK: - Scrolling Slides

extension OnboardingVC: UIScrollViewDelegate {
    
    /// Sets up the basics of scrollview and calls populateSlides.
    
    fileprivate func setupScrollingSlides(scrollView: UIScrollView) {
        scrollView.delegate = self
        let _ = promoImages.map { scrollView.addSubview(PromoView.instantiate(with: $0)) }
        pageControl.numberOfPages = promoImages.count
        pageChanged(pageControl)
    }
    
    /// Updates slide frames and scrollview's content size.
    
    fileprivate func updateScrollingSlidesLayout(scrollView: UIScrollView) {
        let slideSize = scrollView.frame.size
        
        // Update each slide's frame.
        for (index, element) in scrollView.subviews.enumerated() {
            let newOrigin = CGPoint(x: CGFloat(index) * slideSize.width, y: 0)
            let newFrame = CGRect(origin: newOrigin, size: slideSize)
            element.frame = newFrame
        }
        
        // Update scroll view's overall content size.
        let contentWidth = CGFloat(scrollView.subviews.count) * slideSize.width
        scrollView.contentSize = CGSize(width: contentWidth, height: slideSize.height)
    }
    
    /// Calculates and updates page control's current page index.
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = Int(round(fractionalPage))
        // Update only when page number has changed.
        if page != pageControl.currentPage {
            pageControl.currentPage = page
            pageChanged(pageControl)
        }
    }
}

// MARK: - Event Handlers

extension OnboardingVC {
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        let phoneNumberController = PhoneNumberVC.instantiate()
        navigationController?.pushViewController(phoneNumberController, animated: true)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let loginVC = LoginVC.instantiate()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    /// Scrolls content to new offset based on UIPageControl's index.
    
    func pageChanged(_ sender: UIPageControl) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
    }
    
}
