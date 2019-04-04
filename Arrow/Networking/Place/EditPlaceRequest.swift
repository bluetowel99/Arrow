
import APIKit
import UIKit

struct EditPlaceRequest: ARRequest {

    let googlePlaceId: String
    let field: String
    let value: String

    typealias Response = Bool

    var platform: ARPlatform

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/places/\(googlePlaceId)/edit/"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    var parameters: Any? {
        let param = [
            "field": field,
            "value": value
        ]
        return param
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }

    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, field: String, value: String) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.field = field
        self.value = value
    }

}
