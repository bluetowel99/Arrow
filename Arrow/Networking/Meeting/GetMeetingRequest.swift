
import APIKit
import UIKit

struct GetMeetingRequest: ARRequest {
    
    let meeting: ARMeeting
    
    typealias Response = ARMeeting
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/bubbles/\(meeting.bubbleId!)/meetings/\(meeting.identifier!)/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARMeeting {
        guard let meetingDict = object as? NSDictionary,
            let meeting = ARMeeting(with: meetingDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return meeting
    }
    
    init(platform: ARPlatform = ARPlatform.shared, meeting: ARMeeting) {
        self.platform = platform
        self.meeting = meeting
    }
    
}
