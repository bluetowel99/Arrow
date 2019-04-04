
import APIKit

struct RatingRequest: ARRequest {
    
    let userID: Int
    let item: Int
    let rating: Float
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/specials/rating/add"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        return [
            "user": userID,
            "item": item,
            "rating": rating,
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, userID: Int, item: Int, rating: Float) {
        self.platform = platform
        self.userID = userID
        self.item = item
        self.rating = rating
    }
    
}
