
import APIKit
import UIKit

struct GetMediaListRequest: ARRequest {
    
    // TODO(kia): Change response type to array of media info.
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/media/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        // TODO(kia): Parse response to an array of media info.
        if let list = object as? NSArray {
            print(list)
        }
        
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }
    
}
