
import APIKit

struct PlaceLitMeterRequest: ARRequest {
    
    let googlePlaceId: String
    let litPoints: Float
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/lit_meter/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "lit_meter": litPoints,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, litPoints: Float) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.litPoints = litPoints
    }
    
}
