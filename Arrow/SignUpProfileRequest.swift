
import APIKit

struct SignUpProfileRequest: ARRequest {
    
    typealias Response = Bool
    
    var platform: ARPlatform
    var password: String?
    var firstName: String?
    var lastName: String?
    var mobile: String?
    var email:String?
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/user/"
    }
    
    
    
    var parameters: Any? {
        return [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName":lastName,
            "mobile":mobile,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        try updateAppSession(with: object, urlResponse: urlResponse)
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, email:String?, firstName:String?, lastName:String?, mobile:String?, password: String?) {
        self.platform = platform
        self.password = password
        self.email = email
        self.mobile = mobile
        self.firstName = firstName
        self.lastName = lastName
    }
    
}


