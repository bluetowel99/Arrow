
import APIKit

struct UpdateMyProfileRequest: ARRequest {
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var user: ARPerson?
    var password: String?
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/users/me/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        var params: Dictionary<String, Any?> = user?.dictionaryRepresentation() ?? Dictionary<String, Any?>()
        params.removeValue(forKey: ARPerson.Keys.pictureUrl)  // Never update picture field.
        params["password"] = password
        return params.nilsRemoved()
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, user: ARPerson?, password: String?) {
        self.platform = platform
        self.user = user
        self.password = password
    }
    
}
