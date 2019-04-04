
import UIKit
import GoogleMaps
final class MeetingLocationVC: ARKeyboardViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.meetingLocation()
    static var kStoryboardIdentifier: String? = "MeetingLocationVC"


    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    //temp variables to show places
    fileprivate var poiStore = ARPOIStore()
    fileprivate var closePlaces = Array<ARGooglePlace>()
    var meeting: ARMeeting?

    var delegate: CreateMeetingDelegate?
    
    fileprivate var addressString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = self.meeting?.title
        setupView()
        setupTableView()
        getNearbyPlaces()
    }
}

// MARK: - UI Helpers

extension MeetingLocationVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton

        // Searchbar
        searchTextField.clearButtonMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingDidChange(_:)), for: .editingChanged)
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingDidEnd(_:)), for: .editingDidEnd)
    }

    fileprivate func setupTableView() {
        scrollView = tableView
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = NearbyLocationCell.cellHeight
        tableView.register(R.nib.nearbyLocationCell)
        tableView.dataSource = self
        tableView.delegate = self
    }

    fileprivate func updateClosePlaces() {
        // Reset results
        closePlaces.removeAll()
        tableView.reloadData()

        let query = self.searchTextField.text ?? ""

        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            getNearbyPlaces()
        } else {
            updateSearchResults(query)
        }
    }

    fileprivate func updateSearchResults(_ query: String) {
        // Perform new query
        platform.locationManager.getCurrentLocation(forceRefresh: false) { location in
            guard let location = location else {
                print("Search could not get user's location.")
                return
            }



            let radius = 48280  // 30 miles
            self.poiStore.searchWithKeyword(query, lat: location.coordinate.latitude, lng: location.coordinate.longitude, radius: radius, rankBy: .distance, openNow: nil, minPrice: nil, maxPrice: nil, forceRefresh: true) { places in
                self.closePlaces = places ?? [ARGooglePlace]()
                self.tableView.reloadData()
            }
        }
    }

    fileprivate func getNearbyPlaces() {
        platform.locationManager.getCurrentLocation(forceRefresh: false) { location in
            guard let location = location else {
                print("MeetingLocationVC could not get user's location.")
                return
            }

            self.platform.locationManager.getPlacemarks(for: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), completion: { placemarks, error in
                if let error = error {
                    print("Error loading MapsMarkerInfoVC address: \(error.localizedDescription)")
                    return
                }

                self.addressString = ARPlatform.shared.locationManager.getFormattedAddress(for: placemarks?.first)
            })


            let radius = 16090

            ARPOIStore.getNearPOIsList(networkSession: self.networkSession, lat: location.coordinate.latitude, lng: location.coordinate.longitude, radius: radius, type: .restaurant, rankBy: .distance) { places, nextPageToken, error in
                self.closePlaces = places
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Event Handlers

extension MeetingLocationVC {

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createMeetingDidCancel(controller: self)
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func searchTextFieldEditingDidChange(_ sender: Any) {
        updateClosePlaces()
    }

    @IBAction func searchTextFieldEditingDidEnd(_ sender: Any) {
        updateClosePlaces()
    }
}

// MARK: - UITextFieldDelegate Implementation

extension MeetingLocationVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

// MARK: - UITableViewDataSource Implementation

extension MeetingLocationVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return closePlaces.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.nearbyLocationCell)
            if(addressString != nil) {
                cell?.setupCell(title:"Current Location", address: addressString)
            } else {
                cell?.setupCell(title:"Current Location", address: "Loading...")
            }
            return cell ?? UITableViewCell() as! NearbyLocationCell
        }
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.nearbyLocationCell)
            let place = self.closePlaces[indexPath.row]
            let address = place.address
            cell?.setupCell(title: place.name, address: address)
            return cell ?? UITableViewCell()
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 20.0, y: 0.0, width: 50, height: 30))
        headerLabel.backgroundColor = .white
        headerLabel.font = R.font.alegreyaSansMedium(size: 14.0)
        headerLabel.text = "NEARBY"
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 70, height: 30))
        headerView.backgroundColor = .white
        headerView.addSubview(headerLabel)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 30.0
        default:
            return 0.0
        }
    }

}

// MARK: - UITableViewDelegate Implementation

extension MeetingLocationVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meetingLocationConfirmVC = MeetingLocationConfirmVC.instantiate()
        let place = self.closePlaces[indexPath.row]
        self.meeting?.locationId = place.placeId
        meetingLocationConfirmVC.place = self.closePlaces[indexPath.row]
        meetingLocationConfirmVC.meeting = self.meeting
        meetingLocationConfirmVC.delegate = self.delegate
        navigationController?.pushViewController(meetingLocationConfirmVC, animated: true)
    }

}
