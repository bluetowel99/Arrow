
import UIKit
import SVProgressHUD

class POIActivityFeedVC: ARViewController, UINavigationControllerDelegate, StoryboardViewController {
    static var kStoryboard: UIStoryboard = R.storyboard.pOIDetails()
    static var kStoryboardIdentifier: String? = "POIActivityFeedVC"
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var poiStore = ARPOIStore()
    fileprivate var isNewest: Bool = true
    fileprivate var message: String?
    
    fileprivate let imagePickerController = UIImagePickerController()
    fileprivate var images = [UIImage]()
    
    fileprivate(set) var pointOfInterest: ARGooglePlace?
    fileprivate var topComments = [ARActivityFeed]()
    fileprivate var latestComments = [ARActivityFeed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupImagePicker()
        
        refreshData(for: pointOfInterest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        navigationBarTitleStyle = .compactLogo
        isNavigationBarBackTextHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
    }
    
    func setup(pointOfInterest poi: ARGooglePlace, loadFromServer: Bool) {
        self.pointOfInterest = poi
        if loadFromServer {
            getPlaceDetails(placeId: poi.placeId, callback: { (poi, error) in
                if let error = error {
                    print("Error loading POI details: \(error.localizedDescription)")
                    return
                }
                self.pointOfInterest?.copyNonNilData(newPOI: poi!)
                self.refreshData(for: self.pointOfInterest)
            })
        }
    }
}

// MARK: - UI Helpers

extension POIActivityFeedVC {
    
    fileprivate func setupView() {
        useNavigationBarItem = false
        navigationBarTitle = "Activity Feed"
    }
    
    fileprivate func setupTableView() {
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(R.nib.feedSectionHeader(), forHeaderFooterViewReuseIdentifier: FeedSectionHeader.reuseIdentifier)
        tableView.register(R.nib.commentSectionHeader(), forHeaderFooterViewReuseIdentifier: CommentSectionHeader.reuseIdentifier)
    }
    
    fileprivate func setupImagePicker() {
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
    }
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }

    fileprivate func refreshData(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        topComments.removeAll()
        latestComments.removeAll()

//        navigationBarTitle = poi.name
        
        // Setup Top Comments.
        if poi.topComments != nil && (poi.topComments?.count)! > 0 {
            for (_, element) in (poi.topComments?.enumerated())! {
                var activityFeed = ARActivityFeed(with: element)
                activityFeed?.name = poi.name
                topComments.append(activityFeed!)
            }
        }
        
        // Setup Latest Comments.
        if poi.latestComments != nil && (poi.latestComments?.count)! > 0 {
            for (_, element) in (poi.latestComments?.enumerated())! {
                var activityFeed = ARActivityFeed(with: element)
                activityFeed?.name = poi.name
                latestComments.append(activityFeed!)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource Implementation

extension POIActivityFeedVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if latestComments.count == 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return results.count
        switch section {
        case 0: do {
            if latestComments.count == 0 || images.count != 0 {
                return 1
            }
            else {
                return 0
            }
        }
        case 1: do {
            if isNewest {
                return latestComments.count
            }
            else {
                return topComments.count
            }
        }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let identifier = R.reuseIdentifier.addActivityFeedCell
            
            let sendFeedCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            sendFeedCell?.setupTopCell(images: images)
            
            return sendFeedCell ?? UITableViewCell()
        }
        else {
            let results = isNewest ? latestComments : topComments
            let activityFeed = results[indexPath.row]
            
            var identifier = R.reuseIdentifier.activityFeedCell7
            if activityFeed.comment != nil && activityFeed.rating != nil && activityFeed.images.count != 0 {
                identifier = R.reuseIdentifier.activityFeedCell7
            }
            else if activityFeed.comment != nil && activityFeed.images.count != 0 {
                identifier = R.reuseIdentifier.activityFeedCell4
            }
            else if activityFeed.comment != nil && activityFeed.rating != nil {
                identifier = R.reuseIdentifier.activityFeedCell5
            }
            else if activityFeed.images.count != 0 && activityFeed.rating != nil {
                identifier = R.reuseIdentifier.activityFeedCell6
            }
            else if activityFeed.comment != nil {
                identifier = R.reuseIdentifier.activityFeedCell1
            }
            else if activityFeed.rating != nil {
                identifier = R.reuseIdentifier.activityFeedCell3
            }
            else if activityFeed.images.count != 0 {
                identifier = R.reuseIdentifier.activityFeedCell2
            }
            
            let activityFeedCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            activityFeedCell?.setupCell(activityFeed: results[indexPath.row], indexPath: indexPath)
            activityFeedCell?.delegate = self
            
            return activityFeedCell ?? UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate Implementation

extension POIActivityFeedVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CommentSectionHeader.height
        case 1:
            return FeedSectionHeader.height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentSectionHeader.reuseIdentifier) as? CommentSectionHeader
            header?.setupHeader(message: message)
            header?.delegate = self
            return header
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FeedSectionHeader.reuseIdentifier) as? FeedSectionHeader
            header?.setupHeader(status: isNewest)
            header?.delegate = self
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Networking

extension POIActivityFeedVC {
    
    fileprivate func submitRating(googlePlaceId: String, rating: ARPlaceRating, comment: String, images: [UIImage], callback:  ((Error?) -> Void)?) {
        let rateRequest = RatePlaceRequest(googlePlaceId: googlePlaceId, rating: rating, comment: comment, pictures: images)
        SVProgressHUD.show()
        let _ = networkSession?.send(rateRequest) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
    }
    
    fileprivate func commentVote(commentId: String, isUpVote: Bool, callback: (([String: Any]?, Error?) -> Void)?) {
        let voteReq = VoteCommentRequest(commentId: commentId, isUpVote: isUpVote)
        let _ = networkSession?.send(voteReq) { result in
            switch result {
            case .success(let dict):
                callback?(dict, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
    fileprivate func getPlaceDetails(placeId: String, callback: ((ARGooglePlace?, NSError?) -> Void)?) {
        let request = GetPlaceRequest(platform: platform, placeId: placeId)
        SVProgressHUD.show()
        let _ = networkSession?.send(request) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let place):
                callback?(place, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
}

// MARK: - ActivityFeedCellDelegate

extension POIActivityFeedVC: ActivityFeedCellDelegate {
    func openImage(imageUrl: URL?) {
        let poiPhotoViewVC = SpecialPhotoViewController.instantiate()
        poiPhotoViewVC.imageUrl = imageUrl
        self.present(poiPhotoViewVC, animated: true, completion: nil)
    }
    
    func upVoteButtonPressed(cell: ActivityFeedCell, activityFeed: ARActivityFeed?, indexPath: IndexPath?) {
        guard let commentId = activityFeed?.pk else {
            return
        }
        cell.upVoteActionButton.isUserInteractionEnabled = false
        commentVote(commentId: commentId, isUpVote: true) { dict, error in
            cell.upVoteActionButton.isUserInteractionEnabled = true
            if let error = error {
                print("Vote request failed: \(error.localizedDescription)")
            }
            else {
                if let indexPath = indexPath {
                    let results = self.isNewest ? self.latestComments : self.topComments
                    var activityFeed = results[indexPath.row]
                    activityFeed.isVoted = true
                    activityFeed.upvote = true
                    activityFeed.voteCount = dict!["votecount"] as? Int
                    if self.isNewest {
                        self.latestComments.remove(at: indexPath.row)
                        self.latestComments.insert(activityFeed, at: indexPath.row)
                        
                        for i in 0..<self.topComments.count {
                            let comment = self.topComments[i]
                            if comment.pk == activityFeed.pk {
                                self.topComments.remove(at: i)
                                self.topComments.insert(activityFeed, at: i)
                                break
                            }
                        }
                    }
                    else {
                        self.topComments.remove(at: indexPath.row)
                        self.topComments.insert(activityFeed, at: indexPath.row)
                        
                        for i in 0..<self.latestComments.count {
                            let comment = self.latestComments[i]
                            if comment.pk == activityFeed.pk {
                                self.latestComments.remove(at: i)
                                self.latestComments.insert(activityFeed, at: i)
                                break
                            }
                        }
                    }
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    NotificationCenter.default.post(name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
                }
            }
        }
    }
    
    func downVoteButtonPressed(cell: ActivityFeedCell, activityFeed: ARActivityFeed?, indexPath: IndexPath?) {
        guard let commentId = activityFeed?.pk else {
            return
        }
        cell.downVoteActionButton.isUserInteractionEnabled = false
        commentVote(commentId: commentId, isUpVote: false) {dict, error in
            cell.downVoteActionButton.isUserInteractionEnabled = true
            if let error = error {
                print("Vote request failed: \(error.localizedDescription)")
            }
            else {
                if let indexPath = indexPath {
                    let results = self.isNewest ? self.latestComments : self.topComments
                    var activityFeed = results[indexPath.row]
                    activityFeed.isVoted = true
                    activityFeed.upvote = false
                    activityFeed.voteCount = dict!["votecount"] as? Int
                    if self.isNewest {
                        self.latestComments.remove(at: indexPath.row)
                        self.latestComments.insert(activityFeed, at: indexPath.row)
                        
                        for i in 0..<self.topComments.count {
                            let comment = self.topComments[i]
                            if comment.pk == activityFeed.pk {
                                self.topComments.remove(at: i)
                                self.topComments.insert(activityFeed, at: i)
                                break
                            }
                        }
                    }
                    else {
                        self.topComments.remove(at: indexPath.row)
                        self.topComments.insert(activityFeed, at: indexPath.row)
                        
                        for i in 0..<self.latestComments.count {
                            let comment = self.latestComments[i]
                            if comment.pk == activityFeed.pk {
                                self.latestComments.remove(at: i)
                                self.latestComments.insert(activityFeed, at: i)
                                break
                            }
                        }
                    }
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    NotificationCenter.default.post(name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
                }
            }
        }
    }
}

// MARK: - CommentSectionHeaderDelegate

extension POIActivityFeedVC: CommentSectionHeaderDelegate {
    func sendButonPressed(commentTextView: UITextView) {
        if message == nil && images.count == 0 {
            SVProgressHUD.showError(withStatus: "Please leave a comment or select an image at least.")
        }
        else {
            submitRating(googlePlaceId: (pointOfInterest?.placeId)!, rating: ARPlaceRating(), comment: message ?? "", images: images) { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Error submitting to comment.")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Successfully Submitted!")
                    self.images.removeAll()
                    self.message = nil
                    commentTextView.text = ""
                    self.setup(pointOfInterest: self.pointOfInterest!, loadFromServer: true)
                    NotificationCenter.default.post(name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
                }
            }
        }
    }
    
    func sendMessage(message: String) {
        self.message = message
    }
    
    
    func galleryButtonPressed() {
        showImagePicker(type: .photoLibrary)
    }
    
    func photoTakeButtonPressed() {
        showImagePicker(type: .camera)
    }
}

extension POIActivityFeedVC: FeedSectionHeaderDelegate {
    
    func feedUpdatePressed(status: Bool) {
        if isNewest != status {
            isNewest = status
            tableView.reloadData()
        }
    }
}

extension POIActivityFeedVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            images.append(image)
            tableView.reloadSections(IndexSet(integersIn: 0...0), with: .none)
        }        
        dismiss(animated: true, completion: nil)
    }
}
