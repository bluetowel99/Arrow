
import APIKit

struct CreateMeetingRSVPRequest: ARRequest {

    let meeting: ARMeeting
    let going: Bool

    typealias Response = Bool

    var platform: ARPlatform

    var method: HTTPMethod {
        if going {
            return .post
        } else {
            return .delete
        }
    }

    var path: String {
        if let bubbleId = meeting.bubbleId {
            return "bubbles/\(bubbleId)/rsvp/"
        }
        return "bubbles/no_id/rsvp"
    }

    var headerFields: [String: String] {
        return sessionHeaderFields
    }

    var bodyParameters: BodyParameters? {
        var parts: [MultipartFormDataBodyParameters.Part] = []

        do {
            let meetingId = try MultipartFormDataBodyParameters.Part(value: meeting.identifier!, name: "meeting")
            parts = [meetingId]
        } catch let error {
            print("Error parsing meeting id body parameter:\n\(error.localizedDescription)")
        }
        
        return MultipartFormDataBodyParameters(parts: parts)
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        if urlResponse.statusCode < 400 {
            return true
        } else {
            return false
        }
    }

    init(platform: ARPlatform = ARPlatform.shared, meeting: ARMeeting, going: Bool) {
        self.platform = platform
        self.meeting = meeting
        self.going = going
    }
}

