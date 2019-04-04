
import AVFoundation
import UIKit

struct CapturedMediaInfo {
    var photo: UIImage?
    var movieFileURL: URL?
    var captionText: String?
    // TODO(kia): Add location info.
    var selectedMembers: Dictionary<String, ARPerson>?
    
    init(photo: UIImage? = nil, movieFileURL: URL? = nil, captionText: String? = nil, selectedMembers: Dictionary<String, ARPerson>? = nil) {
        self.photo = photo
        self.movieFileURL = movieFileURL
        self.captionText = captionText
        self.selectedMembers = selectedMembers
    }
    
}

protocol CameraFlowDelegate {
    func shouldShowCaption() -> Bool
    func shouldShowLocation() -> Bool
    func didSelectMediaInfo(info: CapturedMediaInfo?)
}

final class CameraVC: ARViewController, StoryboardViewController, DismissableController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.camera()
    static var kStoryboardIdentifier: String? = "CameraVC"
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    fileprivate var focusVisualCueImageView: UIImageView!
    
    var flowDelegate: CameraFlowDelegate?
    
    // MARK: Session Management
    
    fileprivate enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    fileprivate let session = AVCaptureSession()
    fileprivate var isSessionRunning = false
    fileprivate let sessionQueue = DispatchQueue(label: "AR_SESSION_QUEUE", attributes: [], target: nil)
    fileprivate var setupResult: SessionSetupResult = .success
    
    // MARK: Capture Mode
    
    fileprivate enum CaptureMode: Int {
        case photo
        case movie
    }
    
    fileprivate var _captureMode = CaptureMode.photo
    fileprivate var captureMode: CaptureMode {
        get { return _captureMode }
        set { setCaptureMode(newValue) }
    }
    
    // MARK: Device Configuration
    
    fileprivate var _cameraPosition = AVCaptureDevice.Position.unspecified
    fileprivate var cameraPosition: AVCaptureDevice.Position {
        get { return _cameraPosition }
        set { setCameraPosition(newValue) }
    }
    
    fileprivate var _cameraFlashMode = AVCaptureDevice.FlashMode.off
    fileprivate var cameraFlashMode: AVCaptureDevice.FlashMode {
        get { return _cameraFlashMode }
        set {
            setFlashMode(newValue)
            updateFlashButton()
        }
    }
    
    // MARK: AV Input/Output
    
    var videoDeviceInput: AVCaptureDeviceInput!
    var photoOutput = AVCaptureStillImageOutput()
    var movieFileOutput: AVCaptureMovieFileOutput?
    var recordedMovieFileURL: URL?
    fileprivate var backgroundRecordingID: UIBackgroundTaskIdentifier? = nil
    
    // MARK: Delegate
    
    var delegate: DismissableControllerDelegate?
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        setupView()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isStatusBarHidden = true
        startCaptureSession()
        cleanupMovieFile(at: recordedMovieFileURL)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        isStatusBarHidden = false
        stopCaptureSession()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        cleanupMovieFile(at: recordedMovieFileURL)
    }
    
}

// MARK: - UI Helpers

extension CameraVC {
    
    fileprivate func setupView() {
        // Long press gesture recognizer.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(captureButtonLongPressed(_:)))
        captureButton.addGestureRecognizer(longPressGesture)
        
        // Focus visual hint.
        focusVisualCueImageView = UIImageView(image: R.image.focusVisualCue())
        focusVisualCueImageView.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        view.addSubview(focusVisualCueImageView)
        focusVisualCueImageView.isHidden = true
        
        updateFlashButton()
    }
    
    fileprivate func setupCamera() {
        previewView.session = session
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        checkVideoAuthorization()
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    fileprivate func navigateToAddCaptionScreen(with photo: UIImage?) {
        let captionVC = CameraCaptionVC.instantiate()
        captionVC.capturedMediaInfo = CapturedMediaInfo(photo: photo)
        captionVC.delegate = delegate
        captionVC.flowDelegate = flowDelegate
        navigationController?.pushViewController(captionVC, animated: true)
    }
    
    fileprivate func navigateToAddCaptionScreen(with movieFileURL: URL?) {
        let captionVC = CameraCaptionVC.instantiate()
        captionVC.capturedMediaInfo = CapturedMediaInfo(movieFileURL: movieFileURL)
        captionVC.delegate = delegate
        captionVC.flowDelegate = flowDelegate
        navigationController?.pushViewController(captionVC, animated: true)
    }
    
    fileprivate func updateFlashButton() {
        switch cameraFlashMode {
        case .auto:
            flashButton.setImage(R.image.flashAutoIcon(), for: .normal)
        case .off:
            flashButton.setImage(R.image.flashOffIcon(), for: .normal)
        case .on:
            flashButton.setImage(R.image.flashOnIcon(), for: .normal)
        }
    }
    
    fileprivate func showFocusVisualCue(at point: CGPoint) {
        focusVisualCueImageView.transform = CGAffineTransform.identity
        focusVisualCueImageView.alpha = 1.0
        focusVisualCueImageView.center = point
        focusVisualCueImageView.isHidden = false
        let scaleTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.focusVisualCueImageView.transform = scaleTransform
            self.focusVisualCueImageView.alpha = 0.0
        }, completion: { _ in
            self.focusVisualCueImageView.isHidden = true
        })
    }
    
}

// MARK: - AV Session Helpers

extension CameraVC {
    
    /// **Note:** Call this on the session queue.
    
    fileprivate func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        // Add video input.
        do {
            let defaultVideoDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            photoOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            session.addOutput(photoOutput)
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    fileprivate func checkVideoAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
                if granted == false {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            }
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
    }
    
    fileprivate func startCaptureSession() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async { [unowned self] in
                    let message = "Arrow doesn't have permission to use the camera, please change privacy settings"
                    let alertController = UIAlertController(title: "Camera", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Settings", style: .`default`) { action in
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    })
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async { [unowned self] in
                    let message = "Unable to capture media"
                    let alertController = UIAlertController(title: "Camera", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func stopCaptureSession() {
        sessionQueue.async { [unowned self] in
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    fileprivate func setCaptureMode(_ mode: CaptureMode) {
        switch mode {
        case .photo:
            self.session.beginConfiguration()
            self.session.removeOutput(self.movieFileOutput!)
            self.session.sessionPreset = AVCaptureSession.Preset.photo
            self.session.commitConfiguration()
            self.movieFileOutput = nil
            
        case .movie:
            let movieFileOutput = AVCaptureMovieFileOutput()
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = AVCaptureSession.Preset.high
                if let connection = movieFileOutput.connection(with: AVMediaType.video),
                    connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
                self.session.commitConfiguration()
                self.movieFileOutput = movieFileOutput
            }
        }
    }
    
}

// MARK: - Device Configuration

extension CameraVC {
    
    fileprivate func setCameraPosition(_ position: AVCaptureDevice.Position) {
        if _cameraPosition != position {
            _cameraPosition = position
        } else {
            return
        }
        
        sessionQueue.async { [unowned self] in
            var videoDevice = self.videoDeviceInput.device
            
            for device in AVCaptureDevice.devices(for: AVMediaType.video) {
                let captureDevice = device 
                if captureDevice.position == position {
                    videoDevice = captureDevice
                }
            }
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                self.session.removeInput(self.videoDeviceInput)
                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    self.session.addInput(self.videoDeviceInput)
                }
                
                if let connection = self.movieFileOutput?.connection(with: AVMediaType.video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.session.commitConfiguration()
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    fileprivate func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        if _cameraFlashMode != mode {
            _cameraFlashMode = mode
        } else {
            return
        }
        
        let videoDevice = videoDeviceInput.device
        if videoDevice.hasFlash == true {
            do {
                try videoDevice.lockForConfiguration()
                videoDevice.flashMode = mode
                videoDevice.unlockForConfiguration()
            } catch {
                print("Error occured while changing camera flash light: \(error)")
            }
        }
    }
    
    fileprivate func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async { [unowned self] in
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }

                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }

                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
}

// MARK: - Capture Photo & Video

extension CameraVC {
    
    fileprivate func capturePhoto(willCapturePhotoAnimation: (() -> Void)?, completion: @escaping (UIImage?) -> Void) {
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        let outputRect = previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: previewView.videoPreviewLayer.bounds)
        
        sessionQueue.async {
            self.captureMode = .photo
            
            guard let photoOutputConnection = self.photoOutput.connection(with: AVMediaType.video) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            self.photoOutput.captureStillImageAsynchronously(from: photoOutputConnection) { imageBuffer, error in
                DispatchQueue.main.async {
                    willCapturePhotoAnimation?()
                }
                
                guard let jpegImageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer!) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                var image = UIImage(data: jpegImageData)
                
                let imageCGImage = image?.cgImage
                if let imageWidth = imageCGImage?.width, let imageHeight = imageCGImage?.height {
                    let cropRect = CGRect(x: outputRect.origin.x * CGFloat(imageWidth),
                                          y: outputRect.origin.y * CGFloat(imageHeight),
                                          width: outputRect.size.width * CGFloat(imageWidth),
                                          height: outputRect.size.height * CGFloat(imageHeight))
                    if let croppedCGImage = imageCGImage?.cropping(to: cropRect) {
                        image = UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: image!.imageOrientation)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    fileprivate func startRecordingVideo() {
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async { [unowned self] in
            self.captureMode = .movie
            
            guard let movieFileOutput = self.movieFileOutput else {
                return
            }
            
            if movieFileOutput.isRecording == false {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Dispose of previously recorded movie file.
                self.cleanupMovieFile(at: self.recordedMovieFileURL)
                self.recordedMovieFileURL = nil
                
                // Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = self.movieFileOutput?.connection(with: AVMediaType.video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            }
        }
    }
    
    fileprivate func stopRecordingVideo() {
        sessionQueue.async { [unowned self] in
            if self.movieFileOutput?.isRecording == true {
                self.movieFileOutput?.stopRecording()
            }
        }
    }
    
    func cleanupMovieFile(at outputFileURL: URL?) {
        guard let path = outputFileURL?.path else {
            return
        }
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("Could not remove file at url: \(String(describing: outputFileURL))")
            }
        }
    }
    
}

// MARK: - AVCaptureFileOutputRecordingDelegate Implementation

extension CameraVC: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Movie file finishing error: \(error)")
            cleanupMovieFile(at: outputFileURL)
            recordedMovieFileURL = nil
        } else {
            recordedMovieFileURL = outputFileURL
            navigateToAddCaptionScreen(with: outputFileURL)
        }
        
        // End background task.
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskInvalid
            if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
    }
    
}

// MARK: - Event Handlers

extension CameraVC {
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        delegate?.controllerDidDismiss(controller: self)
    }
    
    @IBAction func flashButtonPressed(_ sender: AnyObject) {
        switch cameraFlashMode {
        // The logic only switches between on/off. Auto is not part of our flash modes.
        case .auto:
            cameraFlashMode = .on
        case .off:
            cameraFlashMode = .on
        case .on:
            cameraFlashMode = .off
        }
    }
    
    @IBAction func captureButtonTouchUp(_ sender: AnyObject) {
        // Disable the button until after capture completes/fails.
        captureButton.isUserInteractionEnabled = false
        
        capturePhoto(willCapturePhotoAnimation: {
            self.previewView.videoPreviewLayer.opacity = 0.0
            UIView.animate(withDuration: 0.25) { [unowned self] in
                self.previewView.videoPreviewLayer.opacity = 1.0
            }
        }, completion: { [unowned self] image in
            self.captureButton.isUserInteractionEnabled = true
            self.navigateToAddCaptionScreen(with: image)
        })
    }
    
    @IBAction func captureButtonLongPressed(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startRecordingVideo()
        case .ended:
            stopRecordingVideo()
        default:
            break
        }
    }
    
    @IBAction func switchCameraButtonPressed(_ sender: AnyObject) {
        switch videoDeviceInput.device.position {
        case .unspecified, .front:
            cameraPosition = .back
        case .back:
            cameraPosition = .front
        }
    }
    
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Show focus visual cue.
        let tapPoint = gestureRecognizer.location(in: gestureRecognizer.view)
        showFocusVisualCue(at: tapPoint)
        // Change camra's focal point.
        let devicePoint = self.previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: tapPoint)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
}
