
import APIKit

struct PostPlaceCommentRequest: ARRequest {
    
    let googlePlaceId: String
    let comment: String
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/comments/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "comment": comment
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, comment: String) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.comment = comment
    }
    
}
