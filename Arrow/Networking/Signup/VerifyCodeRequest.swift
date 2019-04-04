
import APIKit

struct VerifyCodeRequest: ARRequest {
    
    let phoneNumber: String
    let deviceUniqueId: String
    let verificationCode: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/signup/verify/"
    }
    
    var parameters: Any? {
        return [
            "mobile": phoneNumber,
            "device_id": deviceUniqueId,
            "passcode": verificationCode,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
    
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, phoneNumber: String, deviceUniqueId: String, verificationCode: String) {
        self.platform = platform
        self.phoneNumber = phoneNumber
        self.deviceUniqueId = deviceUniqueId
        self.verificationCode = verificationCode
    }
    
}
