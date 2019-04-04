
import APIKit

struct AddBubbleMembersRequest: ARRequest {
    
    let bubbleId: String
    let newMembers: [ARPerson]
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/bubbles/\(bubbleId))/members/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        let membersPhoneNums = newMembers.flatMap { $0.phone }
        
        return [
            "members": membersPhoneNums
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: String, newMembers: [ARPerson]) {
        self.platform = platform
        self.bubbleId = bubbleId
        self.newMembers = newMembers
    }
    
}
