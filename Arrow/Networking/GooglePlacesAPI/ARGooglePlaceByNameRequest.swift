
import APIKit
import CoreLocation

class ARGooglePlaceByNameRequest: ARGooglePlaceRequest {

    var searchTerm: String?
    override var parameters: Any? {
        if let lat = self.lat, let lng = self.lng, let searchTerm = self.searchTerm {
            return [
                "key": ARConstants.GooglePlace.key,
                "radius": radius,
                "location": "\(lat),\(lng)",
                "keyword": searchTerm
            ]
        }
        return nil
    }
    
}
