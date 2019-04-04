
import UIKit

final class BookmarksListVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.bookmarksList()
    static var kStoryboardIdentifier: String? = "BookmarksListVC"
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var dataSource = [ARBookmark]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        loadData()
    }
    
}

// MARK: - UI Helpers

extension BookmarksListVC {
    
    fileprivate func setupView() {
        navigationBarTitle = "Bookmarks"
        isNavigationBarBackTextHidden = true
    }
    
    fileprivate func setupTableView() {
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 85.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.landmarkCell)
    }
    
    fileprivate func showPOIDetailsScreen(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        let poiDetailsVC = POIDetailsVC.instantiate()
        poiDetailsVC.setup(pointOfInterest: poi, loadFromServer: true)
        navigationController?.pushViewController(poiDetailsVC, animated: true)
    }
    
    fileprivate func showNavigationScreen(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        let navigationVC = MapNavigationVC.instantiate()
        navigationVC.place = poi
        navigationController?.pushViewController(navigationVC, animated: true)
    }
    
    fileprivate func loadData() {
        getAllMyBookmarks { bookmarks, error in
            if let error = error {
                print("Failed to load bookmarks: \(error.localizedDescription)")
                return
            } else if let bookmarks = bookmarks {
                self.dataSource = bookmarks
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension BookmarksListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: LandmarkCell?
        cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.landmarkCell, for: indexPath)
        
        if let place = dataSource[indexPath.row].place {
            let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
            let distance = platform.locationManager.currentLocalizedDistanceFrom(placeLocation)
            cell?.setupCell(landmark: place, localizedDistance: distance, thumbnailWidth: 75.0)
            cell?.delegate = self
        }
        
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate

extension BookmarksListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var poi = dataSource[indexPath.row].place
        getPlaceDetails(placeId: (poi?.placeId)!) { (googlePlace, error) in
            if let place = googlePlace {
                poi?.copyNonNilData(newPOI: place)
            }
        }
        showPOIDetailsScreen(for: poi)
    }
    
}

// MARK: - LandmarkCellDelegate

extension BookmarksListVC: LandmarkCellDelegate {
    
    func landmarkCellDidPressNavigate(cell: LandmarkCell) {
        showNavigationScreen(for: cell.place)
    }
    
}

// MARK: - Networking

extension BookmarksListVC {
    
    fileprivate func getAllMyBookmarks(callback: (([ARBookmark]?, NSError?) -> Void)?) {
        let request = GetAllMyBookmarksRequest(platform: platform)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let list):
                callback?(list,nil)
            case .failure(let error):
                callback?(nil, error as NSError)
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
