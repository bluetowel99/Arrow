
import APIKit

struct RegisterPhoneRequest: ARRequest {

    let phoneNumber: String
    let deviceUniqueId: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/signup/register/"
    }
    
    var parameters: Any? {
        return [
            "mobile": phoneNumber,
            "device_id": deviceUniqueId,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, phoneNumber: String, deviceUniqueId: String) {
        self.platform = platform
        self.phoneNumber = phoneNumber
        self.deviceUniqueId = deviceUniqueId
    }
    
}
