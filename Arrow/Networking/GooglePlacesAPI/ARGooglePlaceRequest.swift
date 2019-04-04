
import APIKit
import CoreLocation

enum ARGooglePlaceRank: String {
    case prominence = "prominence"
    case distance = "distance"
}

// Google API Docs: https://developers.google.com/places/web-service/search

class ARGooglePlaceRequest: Request {
    
    typealias Response = (places: [ARGooglePlace], nextPageToken: String?)
    
    /// The path URL component.
    var path: String = ""
    
    /// The HTTP request method.
    var method: HTTPMethod = .get
    
    var nextPageToken: String?
    
    /// Defines the distance (in meters).
    /// Defaults to max radius allowed.
    var radius: Int = 50000
    var lat: CLLocationDegrees?
    var lng: CLLocationDegrees?
    var type: ARGooglePlaceType?
    var keyword: String?
    var rankBy: ARGooglePlaceRank?
    var openNow: Bool?
    ///  Valid values range between 0 (most affordable) to 4 (most expensive), inclusive.
    var minPrice: Int?
    var maxPrice: Int?
    
    var platform: ARPlatform {
        return ARPlatform.shared
    }
    
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")!
    }
    
    var parameters: Any? {
        
        if let nextPageToken = nextPageToken {
            return getNextPageParameters(with: nextPageToken)
        }
        
        if let lat = lat, let lng = lng {
            return getQueryParameters(lat: lat, lng: lng, radius: radius)
        }
        
        return nil
        
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard(200..<300).contains(urlResponse.statusCode) else {
            print("Response error (\(urlResponse.statusCode)):\n\(object)")
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let results = object as? [String: Any], let placeDictsArray = results["results"] as? [[String: Any]],
            let places = [ARGooglePlace](with: placeDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        
        let nextPageToken = results["next_page_token"] as? String
        return (places: places, nextPageToken: nextPageToken)
    }
    
    init(lat: CLLocationDegrees?, lng: CLLocationDegrees?, radius: Int?, type: ARGooglePlaceType?, keyword: String?, rankBy: ARGooglePlaceRank?, openNow: Bool?, minPrice: Int?, maxPrice: Int?) {
        self.lat = lat
        self.lng = lng
        self.radius = radius ?? 50000
        self.type = type
        self.keyword = keyword
        self.rankBy = rankBy
        self.openNow = openNow
        self.minPrice = minPrice
        self.maxPrice = maxPrice
    }
    
    /// Returns the next 20 results from a previously run search.
    init(nextPageToken: String) {
        // Setting a pagetoken parameter will execute a search with the same parameters used previously — all parameters other than pagetoken will be ignored.
        self.nextPageToken = nextPageToken
    }
    
}

// MARK: - Private Helpers

extension ARGooglePlaceRequest {
    
    fileprivate func getNextPageParameters(with nextPageToken: String) -> [String: Any] {
        return [
            "key": ARConstants.GooglePlace.key,
            "pagetoken": nextPageToken,
            ]
    }
    
    fileprivate func getQueryParameters(lat: CLLocationDegrees, lng: CLLocationDegrees, radius: Int) -> [String: Any] {
        var params: [String: Any?] = [
            "key": ARConstants.GooglePlace.key,
            "location": "\(lat),\(lng)",
            "radius": radius,
            "type": type?.rawValue,
            "keyword": keyword,
            ]
        
        if let rankBy = rankBy {
            // Note that rankby must not be included if radius is specified.
            params.removeValue(forKey: "radius")
            
            switch rankBy {
            case .distance:
                // For distance, one or both keyword or type keys are required.
                if type != nil || keyword != nil {
                    params["rankby"] = rankBy.rawValue
                } else {
                    params["radius"] = radius
                }
            case .prominence:
                params["rankby"] = rankBy.rawValue
            }
        }
        
        return params.nilsRemoved()
    }
    
}
