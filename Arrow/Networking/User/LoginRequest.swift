
import APIKit

struct LoginRequest: ARRequest {
    
    var userName: String?
    var password: String?
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/users/login/"
    }
    
    var parameters: Any? {
        return [
            "email": userName,
            "password": password,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        try updateAppSession(with: object, urlResponse: urlResponse)
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, userName: String, password: String) {
        self.platform = platform
        self.userName = userName
        self.password = password
    }
    
}
