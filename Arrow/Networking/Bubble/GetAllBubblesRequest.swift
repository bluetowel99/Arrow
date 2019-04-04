
import APIKit
import UIKit

struct GetAllBubblesRequest: ARRequest {
    
    typealias Response = [ARBubble]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/bubbles/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARBubble] {
        guard let bubbleDictsArray = object as? [[String: Any]],
            let bubbles = [ARBubble](with: bubbleDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubbles
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
