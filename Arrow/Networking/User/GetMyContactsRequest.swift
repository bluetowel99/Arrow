
import APIKit

struct GetMyContactsRequest: ARRequest {
    
    typealias Response = [ARPerson]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/contacts/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARPerson] {
        guard let contactsDictsArray = object as? [[String: Any]],
            let contacts = [ARPerson](with: contactsDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return contacts
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
