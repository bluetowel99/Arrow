
import APIKit

struct VoteCommentRequest: ARRequest {
    
    let commentId: String
    let isUpVote: Bool
    
    typealias Response = [String: Any]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .put
    }
    
    var path: String {
        let voteUrl = isUpVote ? "upvote" : "downvote"
        return "/comments/\(commentId)/\(voteUrl)/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let result = object as? [String: Any] else {
            throw ResponseError.unexpectedObject(object)
        }
        
        return result
    }
    
    init(platform: ARPlatform = ARPlatform.shared, commentId: String, isUpVote: Bool) {
        self.platform = platform
        self.commentId = commentId
        self.isUpVote = isUpVote
    }
    
}
