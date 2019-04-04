
import APIKit

struct GetMyCommonBubblesRequest: ARRequest {
    
    typealias Response = [ARBubble]
    
    var platform: ARPlatform
    
    var userId: String
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/users/\(userId)/bubbles/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARBubble] {
        guard let bubbleDictsArray = object as? [[String: Any]],
            let bubbles = [ARBubble](with: bubbleDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubbles
    }
    
    init(platform: ARPlatform = ARPlatform.shared, withUserId userId: String) {
        self.platform = platform
        self.userId = userId
    }
    
}
