
import APIKit

struct GetAllMyCheckInsRequest: ARRequest {
    
    typealias Response = [ARCheckIn]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/users/me/check-ins/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARCheckIn] {
        guard let checkInDictsArray = object as? [[String: Any]],
            let checkIns = [ARCheckIn](with: checkInDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return checkIns
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
