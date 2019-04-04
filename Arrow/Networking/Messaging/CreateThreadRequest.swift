
import APIKit
import UIKit

struct CreateThreadRequest: ARRequest {

    let numbers: String
    let title: String
    typealias Response = ARMessageThread

    var parameters: Any? {
        return [
            "title": title,
            "members" : numbers

        ]
    }

    var platform: ARPlatform

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/messages/"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARMessageThread {
        print(platform.userSession?.authToken ?? "")
        guard let threadDicts = object as? [String: Any],
            let thread = ARMessageThread(with: threadDicts) else {
                throw ResponseError.unexpectedObject(object)
        }
        return thread
    }

    init(platform: ARPlatform = ARPlatform.shared, title: String, numbers: String) {
        self.platform = platform
        self.numbers = numbers
        self.title = title
    }
    
}

