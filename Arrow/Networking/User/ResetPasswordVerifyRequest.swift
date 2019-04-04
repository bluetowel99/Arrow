
import APIKit

struct ResetPasswordVerifyRequest: ARRequest {
    
    var email: String
    var verificationCode: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/password-reset/verify/"
    }
    
    var parameters: Any? {
        return [
            "email": email,
            "passcode": verificationCode,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        try updateAppSession(with: object, urlResponse: urlResponse)
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, email: String, verificationCode: String) {
        self.platform = platform
        self.email = email
        self.verificationCode = verificationCode
    }
    
}
