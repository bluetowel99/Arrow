
import APIKit

struct UpdateMyLocationRequest: ARRequest {
    
    typealias Response = Bool
    
    var long: String
    var lat: String
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/users/me/location/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "longitude": long,
            "latitude": lat,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, longitude: Double, latitude: Double) {
        self.platform = platform
        self.long = String(longitude)
        self.lat = String(latitude)
    }
    
}
