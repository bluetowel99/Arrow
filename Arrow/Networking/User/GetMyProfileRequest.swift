
import APIKit

struct GetMyProfileRequest: ARRequest {
    
    typealias Response = ARPerson
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/users/me/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
