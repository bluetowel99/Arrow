
import APIKit
import UIKit

struct CheckInPlaceRequest: ARRequest {
    
    let googlePlaceId: String
    let removeCheckIn: Bool
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return removeCheckIn ? .delete : .post
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/check-ins/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, removeCheckIn: Bool) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.removeCheckIn = removeCheckIn
    }
    
}
