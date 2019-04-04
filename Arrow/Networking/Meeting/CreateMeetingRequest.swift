
import APIKit
import UIKit

struct CreateMeetingRequest: ARRequest {

    let meeting: ARMeeting?
    let bubbleId: Int

    typealias Response = ARMeeting

    var platform: ARPlatform

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "/bubbles/\(bubbleId)/meetings/"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    var parameters: Any? {
        let params: Dictionary<String, Any?>  = meeting?.dictionaryRepresentation() ?? Dictionary<String, Any?>()
        return params.nilsRemoved()
    }


    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARMeeting {
        guard let meetingDict = object as? NSDictionary,
            let meeting = ARMeeting(with: meetingDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return meeting
    }

    init(platform: ARPlatform = ARPlatform.shared, meeting: ARMeeting?, bubble: Int) {
        self.platform = platform
        self.meeting = meeting
        self.bubbleId = bubble
    }

}
