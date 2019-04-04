
import APIKit
import UIKit

struct GetBubbleMembersRequest: ARRequest {
    
    let bubbleId: Int
    
    typealias Response = [ARPerson]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/bubbles/\(bubbleId)/members/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARPerson] {
        guard let bubbleDictsArray = object as? [[String: Any]],
            let members = [ARPerson](with: bubbleDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return members
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: Int) {
        self.platform = platform
        self.bubbleId = bubbleId
    }
    
}
