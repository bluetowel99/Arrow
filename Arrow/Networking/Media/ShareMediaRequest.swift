
import APIKit
import UIKit

struct ShareMediaRequest: ARRequest {
    
    let mediaId: String
    let bubbleIds: [String]
    let userPhoneNums: [String]
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/media/\(mediaId)/share/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var parameters: Any? {
        var params = [String: String]()
        
        if bubbleIds.isEmpty == false {
            params[ARShareInfo.Keys.bubbleIds] = bubbleIds.joined(separator: ", ")
        }
        
        if userPhoneNums.isEmpty == false {
            params[ARShareInfo.Keys.userIds] = userPhoneNums.joined(separator: ", ")
        }
        
        return params
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, mediaId: String, bubbleIds: [String]?, userPhoneNums: [String]?) {
        self.platform = platform
        self.mediaId = mediaId
        self.bubbleIds = bubbleIds ?? [String]()
        self.userPhoneNums = userPhoneNums ?? [String]()
    }
    
}
