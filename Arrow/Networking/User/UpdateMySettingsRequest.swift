
import APIKit

struct UpdateMySettingsRequest: ARRequest {
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var settings: ARSettings
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/users/me/settings/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return settings.dictionaryRepresentation()
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, settings: ARSettings) {
        self.platform = platform
        self.settings = settings
    }
    
}
