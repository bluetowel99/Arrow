
import APIKit
import UIKit

struct GetAllMessageThreadsRequest: ARRequest {

    typealias Response = [ARMessageThread]

    var platform: ARPlatform

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/messages/"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> [ARMessageThread] {
//        print(platform.userSession?.authToken ?? "")
//        print(object)
        guard let threadDictsArray = object as? [[String: Any]],
            let threads = [ARMessageThread](with: threadDictsArray) else {
                throw ResponseError.unexpectedObject(object)
        }
        return threads
    }

    init(platform: ARPlatform = ARPlatform.shared) {
        self.platform = platform
    }

}
