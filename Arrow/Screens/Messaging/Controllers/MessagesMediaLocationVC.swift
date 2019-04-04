
import Foundation
import CoreLocation

protocol MessagesMediaLocationDelegate {
    func didSelectLocation(place: ARGooglePlace)
}
final class MessagesMediaLocationVC: ARKeyboardViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.messagesMediaLocation()
    static var kStoryboardIdentifier: String? = "MessagesMediaLocationVC"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var placeDelegate: MessagesMediaLocationDelegate?
    
    fileprivate var placemarks = [ARGooglePlace]()
    
    fileprivate var location: CLLocation?
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 100
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        return manager
    }()
    
    func setPlacemarks(placemarks: [ARGooglePlace]?) {
        self.placemarks = placemarks ?? []
        self.tableView.reloadData()
    }
    // MARK: Public Properties
    
    var capturedMediaInfo: CapturedMediaInfo?
    
    // MARK: Private Properties
    
    fileprivate var nearbyLocations = [(title: String?, address: String?)]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: Delegate
    
    var delegate: DismissableControllerDelegate?
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Set Location"
        setupView()
        setupTableView()
        startUpdatingLocation()
        self.locationManager.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        isStatusBarHidden = false
    }
    
}

// MARK: - UI Helpers

extension MessagesMediaLocationVC {
    
    fileprivate func setupView() {
        // Search text field.
        searchTextField.clearButtonMode = .always
        searchTextField.keyboardType = .asciiCapable
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
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
    
}

// MARK: - UITableViewDataSource Implementation

extension MessagesMediaLocationVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placemarks.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: 15.0, y: 0.0, width: 100, height: 30))
        headerLabel.backgroundColor = .white
        headerLabel.textColor = R.color.arrowColors.stormGray()
        headerLabel.font = R.font.alegreyaSansExtraBold(size: 16.0)
        headerLabel.text = "NEARBY"
        view.addSubview(headerLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.nearbyLocationCell)
        let placemark = placemarks[indexPath.row]
        cell?.setupCell(title: placemark.name, address: placemark.address)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension MessagesMediaLocationVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.placeDelegate?.didSelectLocation(place: self.placemarks[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension MessagesMediaLocationVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Event Handlers

extension MessagesMediaLocationVC {
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let _ = self.location, !text.isEmpty {
            self.searchNerabyLocations(term: text)
        } else {
            self.searchNerabyLocations(term: "")
        }
    }
    
}

// MARK: - Location Helpers

extension MessagesMediaLocationVC {
    func startUpdatingLocation() {
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate Implementation

extension MessagesMediaLocationVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.stopUpdatingLocation()
        if let location = locations.first {
            self.location = location
            searchNerabyLocations()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error.localizedDescription)")
    }
}

// MARK: - Networking

extension MessagesMediaLocationVC {
    
    func searchNerabyLocations() {
        guard let location = self.location else {
            return
        }
        
        ARPOIStore.getNearPOIsList(networkSession: networkSession, lat: location.coordinate.latitude, lng: location.coordinate.longitude, radius: 5000, type: .restaurant) { places, nextPageToken, error in
            if let error = error {
                print("Failed searchNerabyLocations: \(error.localizedDescription)")
                return
            }
            self.placemarks = places
            self.tableView.reloadData()
        }
    }
    
    func searchNerabyLocations(term: String) {
        guard let location = self.location else {
            return
        }
        
        let request = ARGooglePlaceAutoCompleteRequest()
        request.lat = location.coordinate.latitude
        request.lng = location.coordinate.longitude
        request.input = term
        let networkSession = ARNetworkSession.shared
        let _ = networkSession.send(request) { result in
            switch result {
            case .success(let places):
                self.placemarks = places
                self.tableView.reloadData()
            case .failure(let error):
                print("Failed searchNerabyLocations: \(error.localizedDescription)")
            }
        }
    }
    
}
