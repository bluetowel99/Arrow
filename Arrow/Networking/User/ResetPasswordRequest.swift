
import APIKit

struct ResetPasswordRequest: ARRequest {
    
    var email: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/password-reset/request/"
    }
    
    var parameters: Any? {
        return [
            "email": email,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, email: String) {
        self.platform = platform
        self.email = email
    }
    
}
