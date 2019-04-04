
import APIKit
import UIKit

struct UpdateBubbleInfoRequest: ARRequest {
    
    let bubbleId: Int
    let title: String
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/bubble/\(bubbleId))"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "title": title,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: Int, title: String) {
        self.platform = platform
        self.bubbleId = bubbleId
        self.title = title
    }
    
}
