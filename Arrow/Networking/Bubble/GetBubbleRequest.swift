
import APIKit
import UIKit

struct GetBubbleRequest: ARRequest {
    
    let bubbleId: Int
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/bubble/\(bubbleId))"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: Int) {
        self.platform = platform
        self.bubbleId = bubbleId
    }
    
}
