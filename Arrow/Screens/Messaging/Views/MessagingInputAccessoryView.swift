
import UIKit
import AVFoundation
// MARK: - Add Bubble Members Delegate Definition

protocol MessagingInputAccessoryViewDelegate {
    func willSendTextMessage(text: String)
    func willSendMediaMessage(mediaList: [ARMediaInputData])
    func willSendPollMessage(poll: ARPoll)
    func willSendLocation(place: ARGooglePlace)
    func willSendAudio(audioUrl: URL)
}


final class MessagingInputAccessoryView: UIView {

    var delegate: MessagingInputAccessoryViewDelegate?
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }
    
    var messageThreadType: ARMessageThreadType = .group {
        didSet {
            updateInputMethodsStackView()
        }
    }
    
    @IBOutlet weak var inputMethodsStackView: UIStackView!
    @IBOutlet weak var inputMethodsStackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioRecordHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var placeholderLabel: UILabel!
    weak var viewContoller: UIViewController?

    @IBOutlet weak var textViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var mediaContainerHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    fileprivate var selectedInputMethod: ARMessagingInputMethod?

    fileprivate var editedMediaRow: Int?

    fileprivate var mediaList: [ARMediaInputData] = []
    fileprivate var pollPreview: MessagingPollPreview?
    fileprivate var audioPreview: MessagesAudioPreviewView?

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename: URL?
    var playerTimer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateInputMethodsStackViewWidth()
    }


    override var intrinsicContentSize: CGSize {
        let fixedWidth = textView.frame.size.width
        
        var textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textSize.height += inputMethodsStackView.frame.height + mediaContainer.frame.height + 18
        return CGSize(width: max(textSize.width, fixedWidth), height: textSize.height)
    }
    
    @objc func inputMethodSelected(_ sender:AnyObject!) {
        guard let inputMethodButton = sender as? ARMessagingInputMethodButton,
            let inputMethod = inputMethodButton.messagingInputMethod else { return }
        
        if selectedInputMethod == inputMethod {
            clearSelectedInputMethod()
        } else {
            select(inputMethod: inputMethod)
        }
    }


    @IBAction func sendAction(_ sender: Any) {

        //send images
        if mediaList.count > 0 {
            self.delegate?.willSendMediaMessage(mediaList: mediaList)
        }
        //send poll
        if let poll = self.pollPreview?.poll {
            self.delegate?.willSendPollMessage(poll: poll)
        }
        if let _ = self.audioPreview, let audioFilename = self.audioFilename {
            self.delegate?.willSendAudio(audioUrl: audioFilename)
        }
        self.delegate?.willSendTextMessage(text: self.textView.text)
        self.textView.text = nil
        self.resetMediaContainer()
        self.endEditing(true)
        self.mediaList = []
        self.mediaCollectionView.reloadData()
    }
}

// MARL: - UITextViewDelegate

extension MessagingInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.invalidateIntrinsicContentSize()
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}

// MARK: - UI Helpers

extension MessagingInputAccessoryView {
    
    func setupView() {
        setupInputMethodsStackView()
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        self.mediaContainerHeightContraint.constant = 0
        self.audioRecordHeightConstraint.constant = 0
    }
    
    func setupInputMethodsStackView() {
        guard let stackView = inputMethodsStackView else { return }
        let defaultInputMethods = inputMethods()
        
        let _ = defaultInputMethods.map {
            let button = ARMessagingInputMethodButton()
            button.setImage($0.image, for: .normal)
            button.addTarget(self, action: #selector(MessagingInputAccessoryView.inputMethodSelected(_:)), for: .touchUpInside)
            button.messagingInputMethod = $0
            button.tintColor = ARMessagingInputMethod.tintColor
            stackView.addArrangedSubview(button)
        }
    }
    
    func updateInputMethodsStackView() {
        for subview in inputMethodsStackView.arrangedSubviews {
            guard let inputMethodButton = subview as? ARMessagingInputMethodButton,
                let buttonInputMethod = inputMethodButton.messagingInputMethod else { continue }
            let allowed = allowedInputMethods()
            inputMethodButton.isHidden = !allowed.contains(buttonInputMethod)
        }
    }
    
    func inputMethods() -> [ARMessagingInputMethod] {
        return [.gallery, .camera, .voice, .location, .poll]
    }
    
    func allowedInputMethods() -> [ARMessagingInputMethod] {
        var allowedInputMethods = inputMethods()
        switch messageThreadType {
        case .direct:
            if let pollIndex = allowedInputMethods.index(of: .poll) {
                allowedInputMethods.remove(at: pollIndex)
            }
        default: ()
        }
        
        return allowedInputMethods
    }
    
}

// MARK: - Layout
private extension MessagingInputAccessoryView {
    
    func inputMethodsStackViewWidth() -> CGFloat {
        let allowedWidth = frame.width - 44.00
        let itemWidth = allowedWidth / CGFloat(ARMessagingInputMethod.allValues.count)
        return itemWidth * CGFloat(allowedInputMethods().count)
    }
    
    func updateInputMethodsStackViewWidth() {
        inputMethodsStackViewWidthConstraint.constant = inputMethodsStackViewWidth()
    }
    
}

// MARK: - Selection
private extension MessagingInputAccessoryView {
    
    func clearSelectedInputMethod() {
        selectedInputMethod = nil
        
        for subview in inputMethodsStackView.arrangedSubviews {
            subview.tintColor = ARMessagingInputMethod.tintColor
        }
    }
    
    func select(inputMethod: ARMessagingInputMethod) {
        selectedInputMethod = inputMethod
        
        for subview in inputMethodsStackView.arrangedSubviews {
            guard let inputMethodButton = subview as? ARMessagingInputMethodButton,
                let buttonInputMethod = inputMethodButton.messagingInputMethod else { continue }
            if inputMethod == buttonInputMethod {
                //inputMethodButton.tintColor = ARMessagingInputMethod.selectedTintColor
            } else {
                //inputMethodButton.tintColor = ARMessagingInputMethod.tintColor
            }
        }
        
        setup(inputMethod: inputMethod)
    }
    
    func presentDrawer(with contentViewController: ARDrawerContentViewController) {
        guard let viewContoller = self.viewContoller else { return }
        let drawer = ARDrawer.instantiate()
        drawer.sourceViewController = viewContoller
        drawer.contentViewController = contentViewController
        viewContoller.resignFirstResponder()
        viewContoller.present(drawer, animated: true, completion: {
            self.clearSelectedInputMethod()
        })
        
    }
    func resetMediaContainer() {
        self.mediaContainerHeightContraint.constant = 0
        self.audioRecordHeightConstraint.constant = 0
        self.mediaList.removeAll()
        self.mediaCollectionView.reloadData()
        self.pollPreview?.removeFromSuperview()
        self.audioPreview?.removeFromSuperview()
        self.audioPreview = nil
        self.pollPreview = nil
        self.textView.text = nil
        self.showTextView(show: true)
        self.placeholderLabel.isHidden = false
        self.layoutIfNeeded()
    }
    func setup(inputMethod: ARMessagingInputMethod) {
        switch inputMethod {
        case .poll:
            self.resetMediaContainer()
            let pollCreationVC = MessagingPollCreationVC.instantiate()
            pollCreationVC.delegate = self
            self.viewContoller?.present(UINavigationController(rootViewController: pollCreationVC), animated: true, completion: nil)
            break
        case .voice:
            self.resetMediaContainer()
            if audioRecorder == nil {
                self.audioRecordHeightConstraint.constant = 215
                requestRecording()
            } else {
                self.audioRecordHeightConstraint.constant = 0
            }
            break
        case.camera:
            if mediaList.count == 0 {
                self.resetMediaContainer()
            }
            let camera = CameraVC.instantiate()
            camera.delegate = self
            camera.flowDelegate = self
            self.viewContoller?.present(UINavigationController(rootViewController: camera), animated: true, completion: nil)
        case .gallery:
            if mediaList.count == 0 {
                self.resetMediaContainer()
            }
            let gallerySharingVC = MessagesGallerySharingVC.instantiate()
            gallerySharingVC.delegate = self
            presentDrawer(with: gallerySharingVC)
            break
        case .location:
            let locationSharingVC = MessagesLocationSharingVC.instantiate()
            locationSharingVC.delegate = self
            presentDrawer(with: locationSharingVC)
            break
        }
    }

}

// MARK: - Selection
extension MessagingInputAccessoryView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessagesMediaCollectionViewCell", for: indexPath) as? MessagesMediaCollectionViewCell
            else { fatalError("unexpected cell in collection view") }

        let data  = self.mediaList[indexPath.row]
        cell.row = indexPath.row
        cell.setData(data: data)
        cell.delegate = self
        return cell

    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList.count
    }

}

extension MessagingInputAccessoryView: MessagesMediaCollectionViewCellProtocol {
    func MessagesMediaCollectionViewCellDidTapDelete(row: Int) {
        if self.mediaList.count > row {
            self.mediaList.remove(at: row)
            if mediaList.count == 0 {
                self.resetMediaContainer()
            }
            self.mediaCollectionView.reloadData()
        }
    }
    func MessagesMediaCollectionViewCellDidTapInfo(row: Int) {
        let locationVC = MessagesMediaLocationVC.instantiate()
        //capturedMediaInfo?.captionText = captionTextField.text
        //locationVC.capturedMediaInfo = capturedMediaInfo
        locationVC.placeDelegate = self
        self.editedMediaRow = row
        viewContoller?.navigationController?.pushViewController(locationVC, animated: true)

    }
}

extension MessagingInputAccessoryView: MessagesMediaLocationDelegate {
    func didSelectLocation(place: ARGooglePlace){
        if let editedMediaRow = self.editedMediaRow, self.mediaList.count > editedMediaRow {
            self.mediaList[editedMediaRow].address = place.address
            self.mediaList[editedMediaRow].placeName = place.name
        }
    }
}
extension MessagingInputAccessoryView: UICollectionViewDelegate {
}

extension MessagingInputAccessoryView: MessagesGallerySharingProtocol {
    func messagesGallerySharingDidCancel() {

    }
    func messagesGallerySharingComplete(images: [ARMediaInputData]){
        self.mediaContainerHeightContraint.constant = 120
        self.layoutIfNeeded()
        self.mediaList += images
        self.mediaCollectionView.reloadData()
    }

}

// MARK - Record Audio-
extension MessagingInputAccessoryView: AVAudioRecorderDelegate, MessagesAudioPreviewViewDelegate, AVAudioPlayerDelegate {

    func requestRecording() {

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecordingAudio()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    func startRecordingAudio() {


        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            self.audioFilename = audioFilename
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {

        if success {
            //recordButton.setTitle("Tap to Re-record", for: .normal)
        audioRecorder?.stop()
        audioRecorder = nil
        self.resetMediaContainer()
        let audioPreview = MessagesAudioPreviewView.instanceFromNib()
        audioPreview.delegate = self
        audioPreview.clipsToBounds = true
        audioPreview.frame = CGRect(x: 15, y: 8, width: 300, height: 37)
        audioPreview.autoresizingMask = [.flexibleWidth]
        audioPreview.timerLabel.text = "0:00"
        self.mediaContainer.addSubview(audioPreview)
        self.mediaContainer.bringSubview(toFront: audioPreview)
        self.mediaContainerHeightContraint.constant = 42
        self.showTextView(show: false)
        self.placeholderLabel.isHidden = true
        self.layoutIfNeeded()
        self.audioPreview = audioPreview
        //self.pollPreview = pollPreview

        } else {
            self.resetMediaContainer()
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        } else {
            finishRecording(success: true)
        }
    }

    @IBAction func doneAudioRecordAction(_ sender: Any) {
        audioRecorder?.stop()
        audioRecorder = nil
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func deleteAudioPreview() {
        self.resetMediaContainer()
    }

    func didTapPlayButton() {
        if let player = self.audioPlayer {
            player.stop()
            self.playerTimer?.invalidate()
            self.audioPreview?.timerLabel.text = "00:00"
            self.audioPlayer = nil
            return
        }
        do {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let sound = try AVAudioPlayer(contentsOf: audioFilename)
        audioPlayer = sound
        audioPlayer.delegate = self
        sound.play()
        self.playerTimer = Timer.scheduledTimer(timeInterval: 1, target: self,selector: #selector(MessagingInputAccessoryView.updateLabel), userInfo: nil, repeats: true)
        } catch {
            
        }
    }

    @objc func updateLabel() {
        self.audioPreview?.timerLabel.text = self.audioPlayer?.currentTime.stringValue
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playerTimer?.invalidate()
        self.audioPreview?.timerLabel.text = "00:00"
        self.audioPlayer = nil
    }
    
}

extension MessagingInputAccessoryView: DismissableControllerDelegate {
    func controllerDidDismiss(controller: UIViewController) {
        self.viewContoller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension MessagingInputAccessoryView: MessagingPollCreationDelegate {
    func didCompleteCreatingPoll(poll:ARPoll) {
        guard let options = poll.options else {
            return
        }
        self.resetMediaContainer()
        let pollPreview = MessagingPollPreview.instanceFromNib()
        pollPreview.clipsToBounds = true
        self.showTextView(show: false)
        self.placeholderLabel.isHidden = true

        pollPreview.frame = CGRect(x: 15, y: 15, width: 293, height: 15 + 63 + 48*options.count)
        pollPreview.autoresizingMask = [.flexibleWidth]
        self.mediaContainer.addSubview(pollPreview)
        self.mediaContainer.bringSubview(toFront: pollPreview)
        pollPreview.setPoll(poll: poll)
        pollPreview.layoutIfNeeded()
        if let options = poll.options {
            self.mediaContainerHeightContraint.constant = CGFloat(15 + 63 + 48*options.count)
        }
        self.layoutIfNeeded()
        self.viewContoller?.presentedViewController?.dismiss(animated: true, completion: nil)
        self.pollPreview = pollPreview
    }
    func didCancelCreatingPoll(){
        self.viewContoller?.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
extension MessagingInputAccessoryView: CameraFlowDelegate {
    func shouldShowCaption() -> Bool {
        return true
    }
    func shouldShowLocation() -> Bool {
        return false
    }
    func didSelectMediaInfo(info: CapturedMediaInfo?) {
        if let info = info {
            if let movieUrl = info.movieFileURL?.absoluteString {
                let inputData = ARMediaInputData(type: .video, image: info.photo, movieUrl: movieUrl)
                inputData.caption = info.captionText
                self.mediaList.append(inputData)
                self.mediaContainerHeightContraint.constant = 120.0
                self.layoutIfNeeded()
                self.mediaCollectionView.reloadData()
            } else {
                let inputData = ARMediaInputData(type: .image, image: info.photo, movieUrl: nil)
                inputData.caption = info.captionText
                self.mediaList.append(inputData)
                self.mediaContainerHeightContraint.constant = 120.0
                self.layoutIfNeeded()
                self.mediaCollectionView.reloadData()
            }
        }
    }
}

extension MessagingInputAccessoryView {
    func showCameraActionSheet() {

        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)

        let photoAction = UIAlertAction(title: "Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let camera = CameraVC.instantiate()
            camera.delegate = self
            camera.flowDelegate = self
            self.viewContoller?.present(UINavigationController(rootViewController: camera), animated: true, completion: nil)
        })
        let videoAction = UIAlertAction(title: "Video", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let camera = CameraVC.instantiate()
            camera.delegate = self
            camera.flowDelegate = self
            self.viewContoller?.present(UINavigationController(rootViewController: camera), animated: true, completion: nil)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })

        optionMenu.addAction(photoAction)
        optionMenu.addAction(videoAction)
        optionMenu.addAction(cancelAction)
        self.viewContoller?.present(optionMenu, animated: true, completion: nil)
    }
}

extension MessagingInputAccessoryView: MessagesLocationSharingDelegate {
    func didSelectPlace(place: ARGooglePlace) {
        self.delegate?.willSendLocation(place: place)
    }

    
}

extension MessagingInputAccessoryView {

    func showTextView(show: Bool) {
        if show {
            self.textViewHeightContraint.constant = 38
        } else {
            self.textViewHeightContraint.constant = 0
        }
        self.layoutIfNeeded()
    }

}
