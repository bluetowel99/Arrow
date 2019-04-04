
import APIKit

struct UpdatePlaceCommentRequest: ARRequest {
    
    let googlePlaceId: String
    let commentId: Int
    let comment: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/comments/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "id": commentId,
            "comment": comment
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, commentId: Int, comment: String) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.commentId = commentId
        self.comment = comment
    }
    
}
