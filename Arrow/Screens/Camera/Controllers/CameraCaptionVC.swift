
import AVFoundation
import UIKit


final class CameraCaptionVC: ARKeyboardViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.cameraCaption()
    static var kStoryboardIdentifier: String? = "CameraCaptionVC"
    
    @IBOutlet weak var moviePreviewPlayerView: PlayerView!
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var captionTextFieldContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: Public Properties
    
    var capturedMediaInfo: CapturedMediaInfo?
    
    // MARK: Private Properties
    
    fileprivate var currentItem: AVPlayerItem?
    
    fileprivate var capturedPhoto: UIImage? {
        didSet {
            showCaptured(photo: capturedPhoto)
        }
    }
    fileprivate var capturedMovieFileURL: URL? {
        didSet {
            showCaptured(movieFileURL: capturedMovieFileURL)
        }
    }
    
    // MARK: Delegate
    
    var delegate: DismissableControllerDelegate?

    // MARK:  Flow Delegate
    var flowDelegate: CameraFlowDelegate?
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        isStatusBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playOnLoop(item: currentItem)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pauseCurrentOnLoopItem()
        moviePreviewPlayerView.player?.replaceCurrentItem(with: nil)
        super.viewWillDisappear(animated)
    }
    
    override func keyboardHeightWillChange(from initHeight: CGFloat, to endHeight: CGFloat, animationDuration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        captionTextFieldContainerBottomConstraint.constant = endHeight
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}

// MARK: - UI Helpers

extension CameraCaptionVC {
    
    fileprivate func setupView() {
        capturedPhoto = capturedMediaInfo?.photo
        capturedMovieFileURL = capturedMediaInfo?.movieFileURL
        captionTextField.attributedPlaceholder = NSAttributedString(string: "Add a caption...", attributes: [NSAttributedStringKey.foregroundColor : R.color.arrowColors.vanillaWhite().withAlphaComponent(0.63)])
        captionTextField.autocapitalizationType = .sentences
        captionTextField.delegate = self
    }
    
    fileprivate func showCaptured(photo: UIImage?) {
        photoPreviewImageView?.image = photo
    }
    
    fileprivate func showCaptured(movieFileURL: URL?) {
        guard let movieFileURL = movieFileURL else {
            return
        }
        
        currentItem = AVPlayerItem(url: movieFileURL)
        moviePreviewPlayerView?.player = AVPlayer()
        playOnLoop(item: currentItem)
    }
    
    fileprivate func playOnLoop(item: AVPlayerItem?) {
        moviePreviewPlayerView?.player?.replaceCurrentItem(with: item)
        moviePreviewPlayerView?.player?.setRepeat(enabled: true)
        moviePreviewPlayerView?.player?.play()
    }
    
    fileprivate func pauseCurrentOnLoopItem() {
        moviePreviewPlayerView?.player?.pause()
        moviePreviewPlayerView?.player?.setRepeat(enabled: false)
    }
    
}

// MARK: - Event Handlers

extension CameraCaptionVC {
    
    @IBAction func setLocationButtonPressed(_ sender: AnyObject) {
        capturedMediaInfo?.captionText = captionTextField.text
        if let flowDelegate = self.flowDelegate {
            if !flowDelegate.shouldShowLocation() {
                flowDelegate.didSelectMediaInfo(info: capturedMediaInfo)
                delegate?.controllerDidDismiss(controller: self)
            }
        } else {
            let locationVC = CameraLocationVC.instantiate()
            locationVC.capturedMediaInfo = capturedMediaInfo
            locationVC.delegate = delegate
        
            navigationController?.pushViewController(locationVC, animated: true)
        }
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension CameraCaptionVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
