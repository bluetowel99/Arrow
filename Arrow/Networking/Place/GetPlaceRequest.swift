
import APIKit
import UIKit

struct GetPlaceRequest: ARRequest {
    
    let placeId: String
    
    typealias Response = ARGooglePlace
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/places/\(placeId)/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let result = object as? [String: Any], let place = ARGooglePlace(with: result) else {
            throw ResponseError.unexpectedObject(object)
        }
        
        return place
    }
    
    init(platform: ARPlatform = ARPlatform.shared, placeId: String) {
        self.platform = platform
        self.placeId = placeId
    }
    
}
