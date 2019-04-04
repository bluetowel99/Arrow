
import APIKit

struct GetAllPlaceCommentsRequest: ARRequest {
    
    let googlePlaceId: String
    
    typealias Response = [ARComment]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/comments/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARComment] {
        guard let commentDictsArray = object as? [[String: Any]],
            let comments = [ARComment](with: commentDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return comments
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, commentId: Int, comment: String) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
    }
    
}
