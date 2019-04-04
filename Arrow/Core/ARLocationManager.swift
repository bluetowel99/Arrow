
import CoreLocation
import UIKit

class ARLocationManager: NSObject {
    
    typealias LocationUpdateCallbackType = (CLLocation?) -> Void
    
    fileprivate let locationManager = CLLocationManager()
    
    /// Handlers to receieve location updates once.
    fileprivate var oneTimeLocationUpdateHandlers = [LocationUpdateCallbackType]()
    
    var lastKnownLocation: CLLocation?
    
    fileprivate var timer: Timer?
    
    override init() {
        super.init()
        self.setupLocationManager()
    }
    
}

// MARK: - Public Methods

extension ARLocationManager {
    
    func getCurrentLocation(forceRefresh: Bool, completion: @escaping LocationUpdateCallbackType) {
        if forceRefresh == false, let location = lastKnownLocation {
            completion(location)
            return
        }
        
        // TODO: Modify oneTimeLocationUpdateHandlers in a thread-safe fashion.
        oneTimeLocationUpdateHandlers.append(completion)
        locationManager.startUpdatingLocation()
    }
    
    func getPlacemarks(for location: CLLocation, completion: @escaping ([CLPlacemark]?, Error?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocode failed: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            completion(placemarks, nil)
        }
    }
    
    func getFormattedAddress(for placemark: CLPlacemark?) -> String? {
        guard let addressDict = placemark?.addressDictionary else {
            return nil
        }
        
        let street = addressDict["Street"] ?? ""
        let city = addressDict["City"] ?? ""
        let state = addressDict["State"] ?? ""
        let address = "\(street), \(city), \(state)"
        
        return address
    }
    
    static func localizedDistance(from: CLLocation?, to: CLLocation) -> String? {
        guard let from = from else {
            return nil
        }
        
        let localizedUnit = Locale.current.usesMetricSystem ? "Km" : "Mi"
        let conversionFactor = Locale.current.usesMetricSystem ? 1000.0 : 1609.344
        let localizedDistance = from.distance(from: to) / conversionFactor
        return String(format: "%.1f %@", localizedDistance, localizedUnit)
    }
    
    func currentLocalizedDistanceFrom(_ location: CLLocation) -> String? {
        return ARLocationManager.localizedDistance(from: lastKnownLocation, to: location)
    }
    
}

// MARK: - Private Helpers

extension ARLocationManager {
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
//        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.sendLocationToServer), userInfo: nil, repeats: false)
//        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.sendLocationToServer), userInfo: nil, repeats: true)
    }
    
    
    @objc fileprivate func sendLocationToServer()
    {
        if(ARPlatform.shared.sessionMode == .loggedIn)
        {
            print("TODO - look for changes in latitude and longitude before creating a server query")
            
            getCurrentLocation(forceRefresh: true) { location in
                guard let location = location else {
                    print("Failed to retrieve current location for sendLocationToServer.")
                    return
                }
                
//                print("ready to update location [:\(location.coordinate.longitude),\(location.coordinate.latitude)]")
                
                let request = UpdateMyLocationRequest(platform: ARPlatform.shared, longitude: location.coordinate.longitude, latitude: location.coordinate.latitude)
                let networkSession = ARNetworkSession.shared
                let _ = networkSession.send(request) { result in
                    switch result {
                    case .success(_):
                        print("Location updated")
                        // TODO need to only load arrowPOIData that is visible on screen
                    //     ARPOIStore.getArrowPOIData()
                    case .failure(let error):
                        print("ERROR: locationManager sendLocationToServer error: \(error)")
                    }
                }
            }
        }
    }
} 

// MARK: - CLLocationManagerDelegate Implementation

extension ARLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = manager.location else {
            return
        }
        
        lastKnownLocation = currentLocation
        
        // Broadcast updated location and remove handlers from the que afterwards.
        var calledHandlerIndexes = [Int]()
        let _ = oneTimeLocationUpdateHandlers.enumerated().map { index, handler in
            handler(currentLocation)
            calledHandlerIndexes.append(index)
        }
       
        let _ = calledHandlerIndexes.enumerated().map {   (index, element) in
            
            if oneTimeLocationUpdateHandlers.indices.contains(index) {
                let _ = oneTimeLocationUpdateHandlers.remove(at: index)
            }
        }
        
        // Stop continuos location monitoring unless needed.
        if oneTimeLocationUpdateHandlers.isEmpty {
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail: \(error.localizedDescription)")
    }
    
}
