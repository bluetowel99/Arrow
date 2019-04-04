
import AVFoundation
import UIKit

final class CameraConfirmVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.cameraConfirm()
    static var kStoryboardIdentifier: String? = "CameraConfirmVC"
    
    @IBOutlet weak var moviePreviewPlayerView: PlayerView!
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var locationInfoView: UIView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationAddressLabel: UILabel!
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var membersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: ARButton!
    
    // MARK: Public Properties
    
    var capturedMediaInfo: CapturedMediaInfo?
    
    // MARK: Private Properties
    
    fileprivate var currentItem: AVPlayerItem?
    
    fileprivate var selectedMembers = [ARPerson]()
    
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
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Confirm"
        setupView()
        setupMembersTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        isStatusBarHidden = false
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMembersTableViewHeight()
    }
    
}

// MARK: - UI Helpers

extension CameraConfirmVC {
    
    fileprivate func setupView() {
        if let members = capturedMediaInfo?.selectedMembers?.values {
            selectedMembers = Array(members)
        }
        capturedPhoto = capturedMediaInfo?.photo
        capturedMovieFileURL = capturedMediaInfo?.movieFileURL
        captionLabel.text = capturedMediaInfo?.captionText
        
        // Setup Location Info Section.
        // TODO: Hide location section if location info is missing.
        if true {
            locationInfoView.removeFromSuperview()
        }
    }
    
    fileprivate func setupMembersTableView() {
        membersTableView.allowsSelection = true
        membersTableView.separatorStyle = .none
        membersTableView.rowHeight = BubbleMemberCell.rowHeight
        membersTableView.dataSource = self
        membersTableView.register(R.nib.bubbleMemberCell)
        // Disable table view's scroll since it's contained within a scrollable container.
        membersTableView.isScrollEnabled = false
    }
    
    fileprivate func updateMembersTableViewHeight() {
        let totalVerticalContentInset = membersTableView.contentInset.bottom + membersTableView.contentInset.top
        membersTableViewHeightConstraint.constant = totalVerticalContentInset + membersTableView.contentSize.height
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
    
    fileprivate func shareUploadedMedia(media: ARMedia) {
        guard let mediaId = media.identifier else {
            return
        }
        
        let bubbleIds = [String]()
        var userPhoneNums: [String]?
        
        // TODO: Aggregate bubbleIds.
        
        if let selectedPersons = capturedMediaInfo?.selectedMembers?.values {
            userPhoneNums = Array(selectedPersons).flatMap { $0.phone }
        }
        
        requestMediaShare(mediaId: mediaId.description, bubbleIds: bubbleIds, userPhoneNums: userPhoneNums)
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension CameraConfirmVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bubbleMemberCell, for: indexPath)
        
        let contactInfo = selectedMembers[indexPath.row]
        memberCell?.setupCell(person: contactInfo)
        
        // Hide last row's separator line.
        if indexPath.row == selectedMembers.count - 1 {
            memberCell?.hideSeparatorLine()
        }
        
        return memberCell ?? UITableViewCell()
    }
    
}

// MARK: - Event Handlers

extension CameraConfirmVC {
    
    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        // Uploading captured video.
        if let videoFile = capturedMediaInfo?.movieFileURL {
            let avAsset = AVURLAsset(url: videoFile, options: nil)
            if let _ = avAsset.encodeVideo(to: .mp4, completion: { outputURL in
                self.requestMediaUpload(photo: nil, movieFileURL: outputURL, caption: self.capturedMediaInfo?.captionText)
            }, failure: { error in
                self.shareButton.hideActivityIndicator()
                print("Video encoding export error: \(String(describing: error?.localizedDescription))")
            }, cancelled: {
                self.shareButton.hideActivityIndicator()
                print("Video encoding export cancelled.")
            }) {
                self.shareButton.showActivityIndicator()
            }
        } else {
            // Uploading captured photo.
            shareButton.showActivityIndicator()
            requestMediaUpload(photo: capturedMediaInfo?.photo, movieFileURL: nil, caption: capturedMediaInfo?.captionText)
        }
    }
    
}

// MARK: - Networking

extension CameraConfirmVC {
    
    fileprivate func requestMediaUpload(photo: UIImage?, movieFileURL: URL?, caption: String?) {
        assert(photo != nil || movieFileURL != nil, "Photo or movie file URL must be provided.")
        
        let uploadMediaReq = UploadMediaRequest(photo: photo, movieFileURL: movieFileURL, caption: caption)
        
        let _ = networkSession?.send(uploadMediaReq) { result in
            switch result {
            case .success(let newMedia):
                self.shareUploadedMedia(media: newMedia)
            case .failure(let error):
                self.shareButton.hideActivityIndicator()
                print("UploadMediaRequest error: \(error)")
            }
        }
    }
    
    fileprivate func requestMediaShare(mediaId: String, bubbleIds: [String]?, userPhoneNums: [String]?) {
        let shareMediaReq = ShareMediaRequest(mediaId: mediaId, bubbleIds: bubbleIds, userPhoneNums: userPhoneNums)
        let _ = networkSession?.send(shareMediaReq) { result in
            switch result {
            case .success(_):
                self.shareButton.hideActivityIndicator()
                self.delegate?.controllerDidDismiss(controller: self)
            case .failure(let error):
                self.shareButton.hideActivityIndicator()
                print("ShareMediaRequest error: \(error)")
            }
        }
    }
    
}

