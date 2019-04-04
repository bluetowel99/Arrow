
import APIKit

struct GetAllMyBookmarksRequest: ARRequest {
    
    typealias Response = [ARBookmark]
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/users/me/bookmarks/"
    }
    
    var headerFields: [String : String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARBookmark] {
        guard let bookmarkDictsArray = object as? [[String: Any]],
            let bookmarks = [ARBookmark](with: bookmarkDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bookmarks
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
