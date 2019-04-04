
import UIKit

final class ProfileVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.profile()
    static var kStoryboardIdentifier: String? = "ProfileVC"
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate weak var profileInfoCell: ProfileInfoCell?
    fileprivate var locationAddress = "Loading..."
    fileprivate var checkIns: [ARCheckIn?]?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        reloadUserProfileFromServer()
        refreshMyLocationInfo()
        loadUsersCheckIns()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarTitleStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}

// MARK: - UI Helpers

extension ProfileVC {
    
    fileprivate func setupView() {
        useNavigationBarItem = true
        isNavigationBarBackTextHidden = true
    }
    
    fileprivate func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.profileInfoCell)
        tableView.register(R.nib.profileActionsCell)
        tableView.register(R.nib.profileSectionHeader(), forHeaderFooterViewReuseIdentifier: ProfileSectionHeader.reuseIdentifier)
        tableView.register(R.nib.nearbyLocationCell)
        tableView.register(R.nib.checkInCell)
    }
    
    fileprivate func refreshMyLocationInfo() {
        let locationManager = platform.locationManager
        locationManager.getCurrentLocation(forceRefresh: true) { location in
            guard let location = location else {
                self.locationAddress = "Failed to load"
                print("Failed to retrieve current location.")
                return
            }
            
            locationManager.getPlacemarks(for: location, completion: { placemarks, error in
                if let error = error {
                    self.locationAddress = "Failed to load"
                    print("Error loading user profile's location placemark: \(error.localizedDescription)")
                    return
                }
                
                self.locationAddress = locationManager.getFormattedAddress(for: placemarks?.first) ?? "Failed to load"
            })
        }
    }
    
    fileprivate func reloadUserProfileFromServer() {
        platform.refreshUserProfile(networkSession: networkSession) { error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            
            self.refreshProfileInfoCell()
        }
    }
    
    fileprivate func refreshProfileInfoCell() {
        if let currentUser = platform.userSession?.user {
            profileInfoCell?.setupCell(person: currentUser)
        }
    }

    fileprivate func loadUsersCheckIns() {
        platform.refreshUserCheckIns(networkSession: networkSession) { error in
            if let error = error {
                print("Error fetching user check ins: \(error.localizedDescription)")
                return
            }

            guard let myCheckIns = self.platform.userSession?.checkIns else { return }

            self.checkIns = myCheckIns
            self.tableView.reloadData()
        }
    }
    
    fileprivate func navigateToBookmarksScreen() {
        let bookmarksVC = BookmarksListVC.instantiate()
        navigationController?.pushViewController(bookmarksVC, animated: true)
    }
    
    fileprivate func navigateToBubblesScreen() {
        let bubblesVC = BubblesListVC.instantiate()
        bubblesVC.bubbleStore = platform.userSession?.bubbleStore
        bubblesVC.view.backgroundColor = .white
        navigationController?.pushViewController(bubblesVC, animated: true)
    }
    
    fileprivate func navigateToFriendsScreen() {
        let friendsVC = FriendsListVC.instantiate()
        navigationController?.pushViewController(friendsVC, animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension ProfileVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MyProfileSection.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = MyProfileSection(rawValue: UInt(section)) else {
            return 1
        }

        switch section {
        case .checkIns:
            guard let myCheckIns = checkIns else { return 0 }
            let rows = myCheckIns.count > 3 ? 3 : myCheckIns.count
            return rows
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        guard let section = MyProfileSection(rawValue: UInt(indexPath.section)) else {
            return UITableViewCell()
        }
        
        switch section {
        case .info:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileInfoCell, for: indexPath)
            profileInfoCell = cell as? ProfileInfoCell
            profileInfoCell?.delegate = self
            refreshProfileInfoCell()
        case .actions:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileActionsCell, for: indexPath)
            (cell as? ProfileActionsCell)?.delegate = self
        case .currentLocation:
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.nearbyLocationCell, for: indexPath)
            let castedcell = cell as? NearbyLocationCell
            castedcell?.setupCell(title: nil, address: locationAddress)
        case .checkIns:
            guard let checkIns = checkIns, let checkIn = checkIns[indexPath.row] else { return UITableViewCell() }
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.checkInCell, for: indexPath)
            let castedCell = cell as? CheckInCell
            castedCell?.setupCell(checkInInfo: checkIn)
        }
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        func dequeueReusableProfileSectionHeader(title: String, showMore: Bool, hideSeparatorLine: Bool) -> ProfileSectionHeader? {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileSectionHeader.reuseIdentifier) as? ProfileSectionHeader
            header?.setupHeader(title: title, showMore: showMore)
            header?.separatorLine.isHidden = hideSeparatorLine
            
            return header
        }
        
        guard let profileSection = MyProfileSection(rawValue: UInt(section)) else {
            return nil
        }
        
        if let title = profileSection.title {
            return dequeueReusableProfileSectionHeader(title: title.uppercased(), showMore: profileSection.canShowMore, hideSeparatorLine: !profileSection.hasSeparatorLine)
        } else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let profileSection = MyProfileSection(rawValue: UInt(section)) else {
            return 0.0
        }
        
        return profileSection.title == nil ? 0.0 : ProfileSectionHeader.height
    }
    
}

// MARK: - ProfileInfoCellDelegate Implementation

extension ProfileVC: ProfileInfoCellDelegate {
    
    func settingsButtonPressed() {
        let generalSettingsVC = SettingPageVC.instantiate()
        generalSettingsVC.pageController = GeneralSettingsController()
        navigationController?.pushViewController(generalSettingsVC, animated: true)
    }
    
}

// MARK: - ProfileActionsCellDelegate Implementation

extension ProfileVC: ProfileActionsCellDelegate {
    
    func profileActionButtonPressed(action: ProfileAction) {
        switch action {
        case .bookmarks:
            navigateToBookmarksScreen()
        case .bubbles:
            navigateToBubblesScreen()
        case .friends:
            navigateToFriendsScreen()
        }
    }
    
}
