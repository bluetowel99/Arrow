
import APIKit

struct DeletePlaceCommentRequest: ARRequest {
    
    let googlePlaceId: String
    let commentId: Int
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .delete
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
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, commentId: Int) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.commentId = commentId
    }
    
}
