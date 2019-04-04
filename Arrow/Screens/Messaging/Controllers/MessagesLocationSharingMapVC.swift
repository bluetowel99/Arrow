
import CoreLocation
import GoogleMaps
import UIKit

final class MessagesLocationSharingMapVC: UIViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.messagesLocationSharingMap()
    static var kStoryboardIdentifier: String? = "MessagesLocationSharingMapVC"
    
    @IBOutlet var mapView: GMSMapView!
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 100
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        return manager
    }()
    
    fileprivate let currentLocationMarker: GMSMarker = {
        let marker = GMSMarker()
        marker.icon = R.image.myLocationMarker()
        marker.isFlat = true
        return marker
    }()

    fileprivate let defaultZoomLevel: Float = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        startUpdatingLocation()
        setupMapStyling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdatingLocation()
    }
    
    func setupMapStyling() {
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.isBuildingsEnabled = false
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
}

// MARK: - Location Helpers

extension MessagesLocationSharingMapVC {
    // TODO(jacob): Reenable location status checking
    func startUpdatingLocation() {
//        let status = CLLocationManager.authorizationStatus()
//        if (status == .restricted) || (status == .denied) || !CLLocationManager.locationServicesEnabled() {
//            return
//        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension MessagesLocationSharingMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if currentLocationMarker.map == nil {
               currentLocationMarker.map = mapView
            }
            currentLocationMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            mapView.animate(toLocation: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
            if mapView.camera.zoom < defaultZoomLevel {
                mapView.animate(toZoom: defaultZoomLevel)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }
}
