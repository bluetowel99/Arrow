
import APIKit
import UIKit

struct DeleteBubbleRequest: ARRequest {

    let bubbleId: Int

    typealias Response = Bool

    var platform: ARPlatform

    var method: HTTPMethod {
        return .delete
    }

    var path: String {
        return "bubbles/\(bubbleId)/"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }

    init(platform: ARPlatform = ARPlatform.shared, bubbleId: Int) {
        self.platform = platform
        self.bubbleId = bubbleId
    }

}

