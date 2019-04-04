
import APIKit
import UIKit

struct BookmarkPlaceRequest: ARRequest {
    
    let googlePlaceId: String
    let removeBookmark: Bool
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return removeBookmark ? .delete : .post
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/bookmarks/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, removeBookmark: Bool) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.removeBookmark = removeBookmark
    }
    
}
