
import APIKit

struct GetMySettingsRequest: ARRequest {
    
    typealias Response = ARSettings
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/users/me/settings/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARSettings {
        guard let dict = object as? [String: Any],
            let settings = ARSettings(with: dict) else {
                throw ResponseError.unexpectedObject(object)
        }
        
        return settings
    }
    
}
