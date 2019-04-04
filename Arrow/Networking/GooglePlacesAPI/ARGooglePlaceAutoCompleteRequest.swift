
import Foundation


import APIKit
import CoreLocation

class ARGooglePlaceAutoCompleteRequest: Request {
    typealias Response = [ARGooglePlace]

    /// The path URL component.
    var path: String = ""

    /// The HTTP request method.
    var method: HTTPMethod = .get

    var lat: CLLocationDegrees?
    var lng: CLLocationDegrees?
    var input: String?
    var platform: ARPlatform {
        return ARPlatform.shared
    }

    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json")!
    }

    var parameters: Any? {
        if let lat = self.lat, let lng = self.lng,let input = self.input {
            return [
                "key": ARConstants.GooglePlace.key,
                "query": input,
                "radius": 50000,
                "location": "\(lat),\(lng)"
            ]
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
        return places
    }
    
}
