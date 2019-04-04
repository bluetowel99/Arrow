
import UIKit
import CoreLocation
import GoogleMaps

protocol MessagesLocationSharingDelegate {
    func didSelectPlace(place: ARGooglePlace)
}

final class MessagesLocationSharingVC: ARDrawerContentViewController, StoryboardViewController, UITextFieldDelegate {
    
    static var kStoryboard: UIStoryboard = R.storyboard.messagesLocationSharing()
    static var kStoryboardIdentifier: String? = "MessagesLocationSharingVC"
    
    @IBOutlet weak var myLocationLabel: UILabel!
    @IBOutlet weak var searchField: UITextField!
    var contentTabBarController: UITabBarController?
    var currentLocation: CLLocation?
    var delegate: MessagesLocationSharingDelegate?
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 100
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        startUpdatingLocation()
        searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchField.resignFirstResponder()
    }
    
	@IBAction func dismiss(_ sender: AnyObject) {
        dismiss()
	}
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        maximize()
        selectTab(at: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TabBarController" {
            guard let tabController = segue.destination as? UITabBarController else { return }
            tabController.tabBar.isHidden = true
            let mapVC = MessagesLocationSharingMapVC.instantiate()
            let searchVC = MessagesLocationSharingSearchTableVC.instantiate()
            searchVC.delegate = self
            tabController.viewControllers = [mapVC, searchVC]
            contentTabBarController = tabController
        }
    }
    
    func selectTab(at index: Int) {
        guard let tabController = contentTabBarController,
            let source = tabController.selectedViewController,
            let destination = tabController.viewControllers?[index] else { return }
        
        let fromView: UIView = source.view
        let toView: UIView = destination.view
        
        if fromView == toView {
            return
        }
        
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve) { (finished:Bool) in
            if finished {
                tabController.selectedIndex = index
            }
        }
    }
    fileprivate func updateMyLocationInfo(placemark: CLPlacemark?) {
        guard let addressDict = placemark?.addressDictionary else {
            return
        }

        let street = addressDict["Street"] ?? ""
        let city = addressDict["City"] ?? ""
        let state = addressDict["State"] ?? ""
        let address = "\(street), \(city), \(state)"
        self.myLocationLabel.text = address
    }

    fileprivate func updateSearchLocations(placeMarks: [ARGooglePlace]?) {
        let tabController = contentTabBarController
        if let searchlistVC = tabController?.viewControllers?[1] as? MessagesLocationSharingSearchTableVC {
            searchlistVC.setPlacemarks(placemarks: placeMarks)
        }

    }


    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let currentLocation = self.currentLocation, !text.isEmpty {
            maximize()
            self.autocompletePlaces(text: text, lat: currentLocation.coordinate.latitude, lng: currentLocation.coordinate.longitude, radius: 50000, callback: { (places, error) in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                    return
                }
                self.updateSearchLocations(placeMarks: places)
            })

        } else {
            minimize()
            selectTab(at: 0)
        }
    }

    fileprivate func autocompletePlaces(text:String?, lat: CLLocationDegrees, lng: CLLocationDegrees, radius: Int, callback: (([ARGooglePlace], NSError?) -> Void)?) {
        let request = ARGooglePlaceAutoCompleteRequest()
        request.lat = lat
        request.lng = lng
        request.input = text
        let networkSession = ARNetworkSession.shared
        let _ = networkSession.send(request) { result in
            switch result {
            case .success(let places):
                callback?(places,nil)
            case .failure(let error):
                callback?([], error as NSError)
            }
        }
    }
}


extension MessagesLocationSharingVC {

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension MessagesLocationSharingVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocode failed: \(error.localizedDescription)")
                    return
                }

                if let placemarks = placemarks, placemarks.isEmpty == false {
                    manager.stopUpdatingLocation()
                    self.updateMyLocationInfo(placemark: placemarks.first)
                } else {
                    print("Problem with geocoder placemarks.")
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }
}

extension MessagesLocationSharingVC: MessagesLocationSharingSearchTableDelegate {
    func didSelectPlace(place: ARGooglePlace) {
        self.delegate?.didSelectPlace(place: place)
        self.dismiss()
    }
}
