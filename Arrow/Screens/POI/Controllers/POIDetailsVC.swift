
extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}

import UIKit
import KMPlaceholderTextView
import Localide
import SVProgressHUD

final class POIDetailsVC: ARKeyboardViewController, StoryboardViewController, UINavigationControllerDelegate {
    
    static var kStoryboard: UIStoryboard = R.storyboard.pOIDetails()
    static var kStoryboardIdentifier: String? = "POIDetailsVC"
    
    @IBOutlet weak var mainOverallView: UIView!
    
    // Image Section
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    // Arrow Section
    @IBOutlet weak var navigateArrowButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Info Section
    @IBOutlet weak var flamesStackView: UIStackView!
    @IBOutlet weak var flamesCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLevelLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var openUntilLabel: UILabel!
    @IBOutlet weak var closingTimeLabel: UILabel!
    
    // Action Buttons
    @IBOutlet weak var locateActionButton: UIButton!
    @IBOutlet weak var phoneActionButton: UIButton!
    @IBOutlet weak var checkInActionButton: UIButton!
    @IBOutlet weak var bookmarkActionButton: UIButton!
    
    // Description Section
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    
    // Rate Section
    @IBOutlet weak var ratePlaceButton:UIButton!
    
    // Friend Check-Ins
    @IBOutlet weak var friendCheckInsSection: UIView!
    @IBOutlet weak var friendCheckInsStackView: UIStackView!
    @IBOutlet weak var sharePlaceButton: UIButton!
    @IBOutlet weak var friendCheckIn1: UIImageView!
    @IBOutlet weak var friendCheckIn2: UIImageView!
    @IBOutlet weak var friendCheckIn3: UIImageView!
    @IBOutlet weak var friendCheckIn4: UIImageView!
    @IBOutlet weak var friendCheckIn5: UIImageView!
    @IBOutlet weak var friendCheckIn6: UIImageView!
    @IBOutlet weak var friendCheckInInitials1: UILabel!
    @IBOutlet weak var friendCheckInInitials2: UILabel!
    @IBOutlet weak var friendCheckInInitials3: UILabel!
    @IBOutlet weak var friendCheckInInitials4: UILabel!
    @IBOutlet weak var friendCheckInInitials5: UILabel!
    @IBOutlet weak var friendCheckInInitials6: UILabel!
    @IBOutlet weak var noCheckInsLabel: UILabel!
    
    // Activity Feed
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityViewHeight: NSLayoutConstraint!
    @IBOutlet weak var fullActivityFeedButton: ARButton!
    
    //More Info
    @IBOutlet var moreInfoView: UIView!
    @IBOutlet var moreInformationLabel: UILabel!
    @IBOutlet var moreInformationButton: UIButton!
    @IBOutlet weak var moreInfoContainerConstraint: NSLayoutConstraint!
    
    //Specials
    @IBOutlet var specials: UIView!
    @IBOutlet var dishesView: UIView!
    @IBOutlet var dishesCollection: UICollectionView!
    @IBOutlet var drinksCollection: UICollectionView!
    var specialDishes = [[String: Any]]()
    var specialDrinks = [[String: Any]]()
    
    var topRatedDishes = [[String: Any]]()
    var topRatedDrinks = [[String: Any]]()
    
    var isBookmarked: Bool = false { didSet { updateBookmarkButton() } }
    var isCheckedIn: Bool = false { didSet { updateCheckInButton() } }
    
    var litMeterVC: POILitMeterVC?
    
    /// Set PointOfInterest using during the setup call.
    fileprivate(set) var pointOfInterest: ARGooglePlace?
    
    //Activity Feed
    fileprivate var isNewest: Bool = true
    fileprivate var message: String?
    
    fileprivate let imagePickerController = UIImagePickerController()
    fileprivate var images = [UIImage]()
    
    fileprivate var topComments = [ARActivityFeed]()
    fileprivate var latestComments = [ARActivityFeed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadActivityData(notification:)), name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
        isNavigationBarBackTextHidden = true
        
        setupView()
        setupTableView()
        setupImagePicker()
        
        refreshData(for: pointOfInterest)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfo" {
            let destinationVC = segue.destination as? POIMoreInfoViewController
            destinationVC?.pointOfInterest = pointOfInterest
        }
        
        if segue.identifier == "foodspecials" || segue.identifier == "drinkspecials" {
            let destinationVC = segue.destination as? SpecialDetailViewController
            destinationVC?.specialDishes = specialDishes
            destinationVC?.specialDrinks = specialDrinks
            destinationVC?.placeName = (pointOfInterest?.name)!
            destinationVC?.selectedCategory = segue.identifier == "foodspecials" ? ARCategories.Food.rawValue : ARCategories.Drink.rawValue
        }
    }
    
    @objc func reloadActivityData(notification: Notification?) {
        self.getPlaceDetails(placeId: (self.pointOfInterest?.placeId)!, callback: { (poi, error) in
            if let error = error {
                print("Error loading POI details: \(error.localizedDescription)")
                return
            }
            self.pointOfInterest?.copyNonNilData(newPOI: poi!)
            self.refreshActivityData(for: self.pointOfInterest)
        })
    }
}

// MARK: - CollectionView Methods
extension POIDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == dishesCollection {
            return topRatedDishes.count
        } else {
            return topRatedDrinks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SpecialsCollectionViewCell
        
        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
                if collectionView == dishesCollection {
                    cell.specialImage.setImage(from: URL.init(string: topRatedDishes[indexPath.row]["photo"] as! String)!) {}
                    cell.rankLabel.text = "#\(indexPath.row + 1) of \(topRatedDishes.count)"
                    cell.itemLabel.text = topRatedDishes[indexPath.row]["name"] as? String
                } else {
                    cell.specialImage.setImage(from: URL.init(string: topRatedDrinks[indexPath.row]["photo"] as! String)!) {}
                    cell.rankLabel.text = "#\(indexPath.row + 1) of \(topRatedDrinks.count)"
                    cell.itemLabel.text = topRatedDrinks[indexPath.row]["name"] as? String
                }
        return cell
    }
}

// MARK: - Public Methods

extension POIDetailsVC {
    
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

extension POIDetailsVC {
    
    fileprivate func setupView() {
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        
        friendCheckInInitials1.layer.cornerRadius = 24
        friendCheckInInitials1.layer.masksToBounds = true
        friendCheckInInitials2.layer.cornerRadius = 24
        friendCheckInInitials2.layer.masksToBounds = true
        friendCheckInInitials3.layer.cornerRadius = 24
        friendCheckInInitials3.layer.masksToBounds = true
        friendCheckInInitials4.layer.cornerRadius = 24
        friendCheckInInitials4.layer.masksToBounds = true
        friendCheckInInitials5.layer.cornerRadius = 24
        friendCheckInInitials5.layer.masksToBounds = true
        friendCheckInInitials6.layer.cornerRadius = 24
        friendCheckInInitials6.layer.masksToBounds = true
        friendCheckIn1.layer.cornerRadius = 24
        friendCheckIn1.layer.masksToBounds = true
        friendCheckIn2.layer.cornerRadius = 24
        friendCheckIn2.layer.masksToBounds = true
        friendCheckIn3.layer.cornerRadius = 24
        friendCheckIn3.layer.masksToBounds = true
        friendCheckIn4.layer.cornerRadius = 24
        friendCheckIn4.layer.masksToBounds = true
        friendCheckIn5.layer.cornerRadius = 24
        friendCheckIn5.layer.masksToBounds = true
        friendCheckIn6.layer.cornerRadius = 24
        friendCheckIn6.layer.masksToBounds = true
        
        //        // Setup comment text view.
        //        commentTextView.returnKeyType = .done
        //        commentTextView.keyboardDismissMode = .onDrag
        //        commentTextView.delegate = self
        //        commentTextView.textColor = R.color.arrowColors.plainBlack()
        //        commentTextView.placeholderColor = R.color.arrowColors.stormGray()
        //        commentTextView.placeholder = "What's happening here..."
        
        // Setup More Info view.
        moreInfoView.layer.shadowColor = R.color.arrowColors.plainBlack().cgColor
        moreInfoView.layer.shadowOpacity = 0.2
        moreInfoView.layer.shadowOffset = CGSize.zero
        moreInfoView.layer.shadowRadius = 4
        
        // Setup Specials view.
        if pointOfInterest?.specials == nil || (pointOfInterest?.specials?.count)! <= 0 {
            self.specials.isHidden = true
        } else {
            
            specialDishes.removeAll()
            specialDrinks.removeAll()
            
            for (_, element) in (pointOfInterest?.specials?.enumerated())! {
                let category = element["name"] as? String
                let topRated = element["top_rated_specials"] as? [[String: Any]]
                let subs = element["sub_categories"] as? [[String: Any]]
                
                if category == "Food" {
                    specialDishes = subs!
                    topRatedDishes = topRated!
                } else {
                    topRatedDrinks = topRated!
                    specialDrinks = subs!
                }
            }
            dishesCollection.reloadData()
            drinksCollection.reloadData()
        }
        
        if pointOfInterest?.moreInformation == nil {
            moreInfoView.isHidden = true
        } else {
            if pointOfInterest?.moreInformation!["description"] as? String == "" {
                moreInfoView.isHidden = true
            } else {
                moreInfoView.isHidden = false
                moreInformationLabel.text = pointOfInterest?.moreInformation!["description"] as? String
                moreInfoContainerConstraint.constant = moreInformationLabel.numberOfVisibleLines > 3 ? 56 : 66
            }
            print(pointOfInterest?.moreInformation!["description"] as Any)
        }
        
        updatePostCommentButton()
    }
    
    fileprivate func setupTableView() {
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        commentsTableView.rowHeight = UITableViewAutomaticDimension
        commentsTableView.separatorStyle = .none
        commentsTableView.register(R.nib.feedSectionHeader(), forHeaderFooterViewReuseIdentifier: FeedSectionHeader.reuseIdentifier)
        commentsTableView.register(R.nib.commentSectionHeader(), forHeaderFooterViewReuseIdentifier: CommentSectionHeader.reuseIdentifier)
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
        
        navigationBarTitle = poi.name
        
        // Set image.
        if let imageUrl = poi.photos?.first?.url {
            activityIndicator.startInfiniteRotationAnimation()
            print(imageUrl.absoluteURL)
            mainImageView.setImage(from: imageUrl) {
                self.activityIndicator.stopInfiniteRotationAnimation()
            }
            print(imageUrl)
        } else {
            mainImageViewTopConstraint.constant = 20
            mainImageViewBottomConstraint.constant = 20
            mainImageView.contentMode = .scaleAspectFit
            mainImageView.image = #imageLiteral(resourceName: "PlaceholderImage")
        }
        
        if let place = pointOfInterest {
            let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
            distanceLabel.text = platform.locationManager.currentLocalizedDistanceFrom(placeLocation)
        }
        
        if pointOfInterest?.moreInformation == nil {
            moreInfoView.isHidden = true
        } else {
            if pointOfInterest?.moreInformation!["description"] as? String == "" {
                moreInfoView.isHidden = true
            } else {
                moreInfoView.isHidden = false
                moreInformationLabel.text = pointOfInterest?.moreInformation!["description"] as? String
                moreInfoContainerConstraint.constant = moreInformationLabel.numberOfVisibleLines > 3 ? 56 : 66
            }
        }
        
        // Setup Specials view.
        if pointOfInterest?.specials == nil || (pointOfInterest?.specials?.count)! <= 0 {
            self.specials.isHidden = true
        } else {
            self.specials.isHidden = false
            specialDishes.removeAll()
            specialDrinks.removeAll()
            
            for (_, element) in (pointOfInterest?.specials?.enumerated())! {
                let category = element["name"] as? String
                let topRated = element["top_rated_specials"] as? [[String: Any]]
                let subs = element["sub_categories"] as? [[String: Any]]
                
                if category == "Food" {
                    specialDishes = subs!
                    topRatedDishes = topRated!
                } else {
                    topRatedDrinks = topRated!
                    specialDrinks = subs!
                }
            }
            dishesCollection.reloadData()
            drinksCollection.reloadData()
        }
        
        // Set basic info.
        titleLabel.text = poi.name
        
        // Set flames.
        let _ = flamesStackView.arrangedSubviews.enumerated().map { index, element in
            guard let flameIcon = element as? UIImageView else { return }
            let index = Float(index + 1)
            let rating = poi.rating ?? 0.0
            
            if rating >= index {
                flameIcon.image = R.image.ratingFlameFilled()
            } else if (index - rating) < 0.5 {
                flameIcon.image = R.image.ratingFlameHalf()
            } else {
                flameIcon.image = R.image.ratingFlameEmpty()
            }
        }
        
        // Set price level.
        let priceLevel =  poi.priceLevel ?? 0
        let attributedString = NSMutableAttributedString(string: "$$$$", attributes: [NSAttributedStringKey.foregroundColor:  R.color.arrowColors.silver()])
        let boldFontAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, priceLevel))
        priceLevelLabel.attributedText = attributedString
        
        // List up to 2 types for the location.
        let locationTypes: [String]? = poi.types?.prefix(2).compactMap { $0.displayName }
        typesLabel.text = locationTypes?.joined(separator: ", ")
        
        // Set location's hours.
        closingTimeLabel.isHidden = false
        if let closingTime = poi.getClosingTime() {
            closingTimeLabel.text = closingTime
            closingTimeLabel.textColor = R.color.arrowColors.oceanBlue()
        } else {
            closingTimeLabel.text = "N/A"
            closingTimeLabel.textColor = UIColor.gray
        }
        
        // Action buttons.
        phoneActionButton.isEnabled = poi.phone?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        
        // Update bookmark and check-in status.
        isBookmarked = poi.isBookmarked
        isCheckedIn = poi.isCheckedIn
        
        updateDescriptionSection()
        updateFriendCheckInsSection()
        
        refreshActivityData(for: poi)
    }
    
    fileprivate func refreshActivityData(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        topComments.removeAll()
        latestComments.removeAll()
        
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
        if latestComments.count == 0 {
            fullActivityFeedButton.isHidden = true
        }
        else {
            fullActivityFeedButton.isHidden = false
        }
        commentsTableView.reloadData()
        setActivityViewHeight()
    }
    
    fileprivate func updateBookmarkButton() {
        let bookmarkImage = isBookmarked ? R.image.bookmarkRoundIcon() : R.image.bookmarkDisabledRoundIcon()
        bookmarkActionButton.setImage(bookmarkImage, for: .normal)
    }
    
    fileprivate func updateCheckInButton() {
        let checkInImage = isCheckedIn ? R.image.checkInRoundIcon() : R.image.checkInDisabledRoundIcon()
        checkInActionButton.setImage(checkInImage, for: .normal)
    }
    
    fileprivate func updatePostCommentButton() {
        //  postCommentButton.tintColor = commentTextView.text.isEmpty ? R.color.arrowColors.stormGray() : R.color.arrowColors.waterBlue()
    }
    
    fileprivate func updateDescriptionSection() {
        // TODO: Use POI description.
        let description = ""
        descriptionLabel.text = description
        emptyDescriptionLabel.isHidden = !description.isEmpty
    }
    
    fileprivate func getInitials(first: String?, last: String?) -> String {
        
        var initials = ""
        
        var personNameComponents = PersonNameComponents()
        personNameComponents.givenName = first
        personNameComponents.familyName = last
        let personNameFormatter = PersonNameComponentsFormatter()
        personNameFormatter.style = .abbreviated
        initials = personNameFormatter.string(from: personNameComponents)
        
        return initials
    }
    
    fileprivate func updateFriendCheckInsSection() {
        if let checkIns = pointOfInterest?.checkIns, checkIns.count > 0 {
            friendCheckInsSection.isHidden = false
            noCheckInsLabel.isHidden = true
            
            if let pictureUrl = checkIns[0].pictureUrl, pictureUrl.absoluteString != "" {
                friendCheckIn1.isHidden = false
                friendCheckIn1.setImage(from: pictureUrl)
                friendCheckInInitials1.isHidden = true
            } else {
                friendCheckInInitials1.isHidden = false
                friendCheckIn1.isHidden = true
                friendCheckInInitials1.text = getInitials(first: pointOfInterest?.checkIns?[0].firstName, last: pointOfInterest?.checkIns?[0].lastName)
            }
            friendCheckIn1.setNeedsDisplay()
            
            friendCheckInInitials2.isHidden = true
            friendCheckIn2.isHidden = true
            friendCheckInInitials3.isHidden = true
            friendCheckIn3.isHidden = true
            friendCheckInInitials4.isHidden = true
            friendCheckIn4.isHidden = true
            friendCheckInInitials5.isHidden = true
            friendCheckIn5.isHidden = true
            friendCheckInInitials6.isHidden = true
            friendCheckIn6.isHidden = true
            
            if((pointOfInterest?.checkIns?.count)! > 1) {
                if (((pointOfInterest?.checkIns?[1].pictureUrl) != nil) && pointOfInterest?.checkIns?[1].pictureUrl?.absoluteString != "") {
                    friendCheckIn2.isHidden = false
                    friendCheckIn2.setImage(from: (pointOfInterest?.checkIns?[1].pictureUrl)!)
                    friendCheckInInitials2.isHidden = true
                } else {
                    friendCheckInInitials2.isHidden = false
                    friendCheckIn2.isHidden = true
                    friendCheckInInitials2.text = getInitials(first: pointOfInterest?.checkIns?[1].firstName, last: pointOfInterest?.checkIns?[1].lastName)
                }
                friendCheckIn2.setNeedsDisplay()
            }
            
            if((pointOfInterest?.checkIns?.count)! > 2) {
                if (((pointOfInterest?.checkIns?[2].pictureUrl) != nil) && pointOfInterest?.checkIns?[2].pictureUrl?.absoluteString != "") {
                    friendCheckIn3.isHidden = false
                    friendCheckIn3.setImage(from: (pointOfInterest?.checkIns?[2].pictureUrl)!)
                    friendCheckInInitials3.isHidden = true
                } else {
                    friendCheckInInitials3.isHidden = false
                    friendCheckIn3.isHidden = true
                    friendCheckInInitials3.text = getInitials(first: pointOfInterest?.checkIns?[2].firstName, last: pointOfInterest?.checkIns?[2].lastName)
                }
                friendCheckIn3.setNeedsDisplay()
            }
            
            if((pointOfInterest?.checkIns?.count)! > 3) {
                if (((pointOfInterest?.checkIns?[3].pictureUrl) != nil) && pointOfInterest?.checkIns?[3].pictureUrl?.absoluteString != "") {
                    friendCheckIn4.isHidden = false
                    friendCheckIn4.setImage(from: (pointOfInterest?.checkIns?[3].pictureUrl)!)
                    friendCheckInInitials4.isHidden = true
                } else {
                    friendCheckInInitials4.isHidden = false
                    friendCheckIn4.isHidden = true
                    friendCheckInInitials4.text = getInitials(first: pointOfInterest?.checkIns?[3].firstName, last: pointOfInterest?.checkIns?[3].lastName)
                }
                friendCheckIn4.setNeedsDisplay()
            }
            
            if((pointOfInterest?.checkIns?.count)! > 4) {
                if (((pointOfInterest?.checkIns?[4].pictureUrl) != nil) && pointOfInterest?.checkIns?[4].pictureUrl?.absoluteString != "") {
                    friendCheckIn5.isHidden = false
                    friendCheckIn5.setImage(from: (pointOfInterest?.checkIns?[4].pictureUrl)!)
                    friendCheckInInitials5.isHidden = true
                } else {
                    friendCheckInInitials5.isHidden = false
                    friendCheckIn5.isHidden = true
                    friendCheckInInitials5.text = getInitials(first: pointOfInterest?.checkIns?[4].firstName, last: pointOfInterest?.checkIns?[4].lastName)
                }
                friendCheckIn5.setNeedsDisplay()
            }
            
            if((pointOfInterest?.checkIns?.count)! > 5) {
                if (((pointOfInterest?.checkIns?[5].pictureUrl) != nil) && pointOfInterest?.checkIns?[5].pictureUrl?.absoluteString != "") {
                    friendCheckIn6.isHidden = false
                    friendCheckIn6.setImage(from: (pointOfInterest?.checkIns?[5].pictureUrl)!)
                    friendCheckInInitials6.isHidden = true
                } else {
                    friendCheckInInitials6.isHidden = false
                    friendCheckIn6.isHidden = true
                    friendCheckInInitials6.text = getInitials(first: pointOfInterest?.checkIns?[5].firstName, last: pointOfInterest?.checkIns?[5].lastName)
                }
                friendCheckIn6.setNeedsDisplay()
            }
            
            if((pointOfInterest?.checkIns?.count)! > 6) {
                print("TODO: make the +x image and label and show it")
            }
        } else {
            friendCheckInsSection.isHidden = true
            noCheckInsLabel.isHidden = false
        }
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension POIDetailsVC: UITableViewDataSource {
    
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
                return latestComments.count > ARConstants.ACTIVITY_FEED_COUNT ? ARConstants.ACTIVITY_FEED_COUNT : latestComments.count //latestComments.count
            }
            else {
                return topComments.count > ARConstants.ACTIVITY_FEED_COUNT ? ARConstants.ACTIVITY_FEED_COUNT : topComments.count //topComments.count
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

extension POIDetailsVC: UITableViewDelegate {
    
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

// MARK: - Logic

extension POIDetailsVC {
    
    fileprivate func setActivityViewHeight() {
        commentsTableView.contentOffset.y = 0
        commentsTableView.layoutIfNeeded()
        activityViewHeight.constant = commentsTableView.contentSize.height + 130
    }
    
    fileprivate func performCheckIn() {
        guard let placeId = pointOfInterest?.placeId else {
            return
        }
        
        checkIn(placeId: placeId) { error in
            if let error = error {
                print("Check-in request failed: \(error.localizedDescription)")
            } else {
                self.isCheckedIn = true
            }
        }
    }
    
    fileprivate func performBookmark() {
        guard let placeId = pointOfInterest?.placeId else {
            return
        }
        
        isBookmarked = !isBookmarked
        bookmarkActionButton.isUserInteractionEnabled = false
        
        bookmark(placeId: placeId, removeBookmark: !isBookmarked) { error in
            self.bookmarkActionButton.isUserInteractionEnabled = true
            if let error = error {
                // Revert bookmarked state due to error.
                self.isBookmarked = !self.isBookmarked
                print("Bookmark request failed: \(error.localizedDescription)")
            }
        }
    }
    
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
}

// MARK: - Event Handlers

extension POIDetailsVC {
    
    @IBAction func navigationMenuBarButtonPressed(_ sender: AnyObject) {
        // TODO: Show extended slide-up menu.
    }
    
    @IBAction func activityFeedButtonPressed(_ sender: Any) {
        let poiActivityFeedVC = POIActivityFeedVC.instantiate()
        poiActivityFeedVC.setup(pointOfInterest: pointOfInterest!, loadFromServer: true)
        navigationController?.pushViewController(poiActivityFeedVC, animated: true)
    }
    
    @IBAction func locateActionButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func navigateArrowButtonPressed(_ sender: Any) {
        if let destination = pointOfInterest {
            let location = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            Localide.sharedManager.promptForDirections(toLocation: location,  rememberPreference: true, onCompletion: nil)
        } else {
            print("Couldn't retrieve POI")
        }
    }
    
    @IBAction func phoneActionButtonPressed(_ sender: AnyObject) {
        guard let phoneNum = pointOfInterest?.phone else {
            return
        }
        
        platform.callPhoneNumber(phoneNum)
    }
    
    @IBAction func checkInActionButtonPressed(_ sender: AnyObject) {
        performCheckIn()
    }
    
    @IBAction func bookmarkActionButtonPressed(_ sender: AnyObject) {
        performBookmark()
    }
    
    @IBAction func ratePlaceButtonPressed(_ sender: AnyObject) {
        guard let place = pointOfInterest,
            let rateVC = UIStoryboard(name: "RatePlace", bundle: nil).instantiateViewController(withIdentifier: "ratePlaceVC") as? RatePlaceViewController else { return }
        rateVC.googlePlace = place
        self.navigationController?.show(rateVC, sender: self)
    }
    
    
    @IBAction func sharePlaceButtonPressed(_ sender: AnyObject) {
        var description = ""
        if let name = pointOfInterest?.name {
            description = "I really enjoyed \(String(describing: name))!"
        }
        if let category = pointOfInterest?.types?.first?.displayName {
            description = description + "\n\nCheck out this \(category)"
            if let address = pointOfInterest?.address {
                description = description + " at \(String(describing: address))\n"
            } else {
                description = description + "\n"
            }
        } else if let address = pointOfInterest?.address {
            description = description + " at \(String(describing: address))\n"
        }
        
        description = description + "https://itunes.apple.com/us/app/arrow-interactive-map/id1186005857?mt=8"
        let objectsToShare = [description] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        // TODO: Exclude acitivities based on the final content that's being shared.
        activityVC.excludedActivityTypes = [.assignToContact]
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        present(activityVC, animated: true, completion: nil)
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
}

// MARK: - UITextViewDelegate Implementation

extension POIDetailsVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Limit to single line comments. Done button resigns first responder.
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePostCommentButton()
    }
    
}

// MARK: - Networking

extension POIDetailsVC {
    
    fileprivate func checkIn(placeId: String, callback: ((Error?) -> Void)?) {
        
        let checkInReq = CheckInPlaceRequest(googlePlaceId: placeId, removeCheckIn: false)
        let _ = networkSession?.send(checkInReq) { result in
            switch result {
            case .success:
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
        
        // check to see if the lit meter is enabled
        if let litMeterEnabled = pointOfInterest?.litMeterEnabled, litMeterEnabled {
            litMeterVC = POILitMeterVC.instantiate()
            litMeterVC?.setPlace(place: pointOfInterest!)
            litMeterVC?.litMeterDelegate = self
            self.addChildViewController(childController: litMeterVC!, on: mainOverallView)
            self.view.addSubview(litMeterVC!.view)
            litMeterVC!.didMove(toParentViewController: self)
        }
    }
    
    fileprivate func bookmark(placeId: String, removeBookmark: Bool, callback: ((Error?) -> Void)?) {
        let bookmarkReq = BookmarkPlaceRequest(googlePlaceId: placeId, removeBookmark: removeBookmark)
        let _ = networkSession?.send(bookmarkReq) { result in
            switch result {
            case .success:
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
    }
    
    fileprivate func getPlaceDetails(placeId: String, callback: ((ARGooglePlace?, NSError?) -> Void)?) {
        let request = GetPlaceRequest(platform: platform, placeId: placeId)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let place):
                callback?(place, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
}

extension POIDetailsVC: POILitMeterDelegate {
    
    func litMeterWillClose() {
        litMeterVC?.willMove(toParentViewController: nil)
        litMeterVC?.view.removeFromSuperview()
        litMeterVC?.removeFromParentViewController()
    }
}

// MARK: - ActivityFeedCellDelegate

extension POIDetailsVC: ActivityFeedCellDelegate {
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
        commentVote(commentId: commentId, isUpVote: true) {dict, error in
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
                    self.commentsTableView.reloadRows(at: [indexPath], with: .none)
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
                    self.commentsTableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
}

// MARK: - CommentSectionHeaderDelegate

extension POIDetailsVC: CommentSectionHeaderDelegate {
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

extension POIDetailsVC: FeedSectionHeaderDelegate {
    
    func feedUpdatePressed(status: Bool) {
        if isNewest != status {
            isNewest = status
            commentsTableView.reloadData()
        }
    }
}

extension POIDetailsVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            images.append(image)
            commentsTableView.reloadSections(IndexSet(integersIn: 0...0), with: .none)
            setActivityViewHeight()
        }
        dismiss(animated: true, completion: nil)
    }
}
