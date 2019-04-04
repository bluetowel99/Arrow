
import APIKit

struct DeleteBubbleMembersRequest: ARRequest {
    
    let bubbleId: Int
    let toBeDeletedMembers: [ARPerson]
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .delete
    }
    
    var path: String {
        return "/bubbles/\(bubbleId)/members/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        let membersIds = toBeDeletedMembers.flatMap { $0.identifier }
        
        return [
            "members": membersIds
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: Int, toBeDeletedMembers: [ARPerson]) {
        self.platform = platform
        self.bubbleId = bubbleId
        self.toBeDeletedMembers = toBeDeletedMembers
    }
    
}
