
import UIKit
import SVProgressHUD

final class MapsMarkerInfoVC: UIViewController, StoryboardViewController {
    static var kStoryboard: UIStoryboard = R.storyboard.mapsMarkerInfo()
    static var kStoryboardIdentifier: String? = "MapsMarkerInfoVC"
    
    fileprivate let percentageFormatter: NumberFormatter = {
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        return percentageFormatter
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var imageBackingView: UIView!
    @IBOutlet weak var batteryIndicator: BatteryIndicator!
    @IBOutlet weak var batteryPercentageLabel: UILabel!
    
    @IBOutlet weak var controlsStackView: UIStackView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var leftDivider: UIImageView!
    @IBOutlet weak var batteryIndicatorStackView: UIStackView!
    @IBOutlet weak var rightDivider: UIImageView!
    @IBOutlet weak var lastActiveLabel: UILabel!
    @IBOutlet var locationSharingButton: UIButton!
    
    var person: ARPerson? {
        didSet {
            guard let newPerson = person else { return }
            setup(for: newPerson)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        imageBackingView.layer.cornerRadius = 33
        controlsStackView.addArrangedSubview(locationSharingButton)
        
        setLocalizableStrings()
    }

    @IBAction func viewProfile(_ sender: Any) {
        print("view profile")
        let alertController = UIAlertController(title: "Show Edit/View Profile UI", message: nil, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func chat(_ sender: Any) {
        SVProgressHUD.showInfo(withStatus: "Chat coming soon!")
//        ARPlatform.mainTabController?.selectTab(tabItem: .messaging)
    }
    
    @IBAction func toggleLocationSharing(_ sender: Any) {
        print("toggle location sharing")
        guard var _ = person else { return }
        
        person?.toggleLocationSharing()
        updateLocationSharingButtonTitle()
    }
}

// MARK: - UI Helpers

private extension MapsMarkerInfoVC {
    func setup(for person: ARPerson) {
        if person.filteredPhone() == ARPlatform.shared.userSession?.user?.filteredPhone() {
            locationSharingButton.isHidden = false
            chatButton.isHidden = true
            leftDivider.isHidden = true
            batteryIndicatorStackView.isHidden = true
            rightDivider.isHidden = true
            lastActiveLabel.isHidden = true

            // Let user know battery percentage is not available
            batteryPercentageLabel.text = "N/A"

            profileButton.setTitle(R.string.maps.mapsEditProfileButtonTitle(), for: .normal)
            updateLocationSharingButtonTitle()
            

            addressLabel.text = "Loading..."
            let locationManager = ARPlatform.shared.locationManager
            locationManager.getCurrentLocation(forceRefresh: true) { location in
                guard let location = location else {
                    print("Failed to retrieve current location.")
                    return
                }
                
                locationManager.getPlacemarks(for: location, completion: { placemarks, error in
                    if let error = error {
                        print("Error loading MapsMarkerInfoVC address: \(error.localizedDescription)")
                        return
                    }
                    
                    let address = locationManager.getFormattedAddress(for: placemarks?.first)
                    self.addressLabel.text = address
                })
            }
            
        } else {
            locationSharingButton.isHidden = true
            chatButton.isHidden = false
            leftDivider.isHidden = false
            batteryIndicatorStackView.isHidden = false
            rightDivider.isHidden = false
            lastActiveLabel.isHidden = false

            imageView.image = person.thumbnail

            // TODO: Backend always return 70%
            batteryIndicator.percentage = person.batteryPercentage!
            batteryPercentageLabel.text = percentageFormatter.string(from: NSNumber(value: person.batteryPercentage! / 100))

            // TODO: Hidden in story until functionality is provided
            profileButton.setTitle(R.string.maps.mapsViewProfileButtonTitle(), for: .normal)

            
            let locationManager = ARPlatform.shared.locationManager
            addressLabel.text = "Loading..."
            locationManager.getPlacemarks(for: CLLocation(latitude: (person.currentPosition?.latitude)!, longitude: (person.currentPosition?.longitude)!), completion: { placemarks, error in
                if let error = error {
                    print("Error loading MapsMarkerInfoVC address: \(error.localizedDescription)")
                    return
                }
                
                let address = locationManager.getFormattedAddress(for: placemarks?.first)
                self.addressLabel.text = address
            })
        }
        
        if let url = person.pictureUrl {
            imageView.setImage(fromFirebaseUrl: url, completion: {
                self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                self.imageView.clipsToBounds = true
            })
        }
        nameLabel.text = person.displayName()
    }
    
    func setLocalizableStrings() {
        chatButton.setTitle(R.string.maps.mapsChatButtonTitle(), for: .normal)
    }
    
    func updateLocationSharingButtonTitle() {
        guard let _person = person else { return }
        
        if _person.isLocationSharingEnabled! {
            locationSharingButton.setTitle(R.string.maps.mapsTurnOffLocationSharingButtonTitle(), for: .normal)
        } else {
            locationSharingButton.setTitle(R.string.maps.mapsTurnOnLocationSharingButtonTitle(), for: .normal)
        }
    }
}
