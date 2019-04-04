
import APIKit

struct UpdateMyDeviceRequest: ARRequest {
    
    typealias Response = Bool
    
    var firebaseToken: String
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/users/me/fcm-token/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "fcm_token": firebaseToken,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, token: String) {
        self.platform = platform
        self.firebaseToken = token
    }
    
}
