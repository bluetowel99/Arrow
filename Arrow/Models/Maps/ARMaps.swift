
import CoreLocation

struct ARMaps {
    
    var poiStore: ARPOIStore = ARPOIStore()

    func getPOI(location: CLLocation, callback: (([ARGooglePlace]?) -> Void)?) {
        poiStore.fetchPOIs(lat: location.coordinate.latitude, lng: location.coordinate.longitude, radius: 1000, forceRefresh: true) { places in
            callback?(places)
        }
    }


}
