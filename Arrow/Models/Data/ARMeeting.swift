
import UIKit

public enum ARMeetingRVSPStatus: Int {
    case going
    case notGoing
    case unanswered
}

/// Arrow's Meeting data model.
struct ARMeeting {

    var identifier: Int?
    var bubbleId: Int?
    var title: String
    var description: String?
    var date: Date?
    var locationId: String?
    var longitude: Double?
    var latitude: Double?
    var rsvps: [ARPerson]?
}

// MARK: - Dictionariable Implementation

extension ARMeeting: Dictionariable {

    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var bubbleId = "bubble_id"
        static var title = "title"
        static var description = "description"
        static var date = "time"
        static var location = "location"
        static var geometry = "geometry"
        static var lng = "lng"
        static var lat = "lat"
        static var placeId = "place_id"
        static var rsvps = "attending"
    }

    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary,
            let title = dictionary[Keys.title] as? String, let bubbleId = dictionary[Keys.bubbleId] as? Int else {
                print("Bad data in ARMeeting Creation");
                return nil
        }

        // Identifier.
        identifier = dictionary[Keys.identifier] as? Int
        self.bubbleId = bubbleId
        // Title.
        self.title = title
        let locationDictionary = dictionary[Keys.location] as? Dictionary<String, Any>
        let geometryDictionary = locationDictionary?[Keys.geometry] as? Dictionary<String, Any>
        let sublocationDictionary = geometryDictionary?[Keys.location] as? Dictionary<String, Any>
        self.locationId = locationDictionary?[Keys.placeId] as? String
        self.longitude = sublocationDictionary?[Keys.lng] as? Double
        self.latitude = sublocationDictionary?[Keys.lat] as? Double
        self.description = dictionary[Keys.description] as? String
        if let dateString = dictionary[Keys.date] as? String {
            date = serverDateFormatter.date(from: dateString)
        }

        // RSVPs
        if let rsvpsdicts = dictionary[Keys.rsvps] as? [Dictionary<String, Any>] {
            rsvps = rsvpsdicts.flatMap { ARPerson(with: $0) }
        } else {
            rsvps = []
        }
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.bubbleId: bubbleId,
            Keys.title: title,
            Keys.description: description,
            Keys.date: iso8601CombinedDateTimeFormatter.string(from: date!),
            Keys.location: locationId,
            Keys.lng: longitude,
            Keys.lat: latitude,
            ]
        return dict.nilsRemoved()
    }

    func dateString() -> String {
        guard let date = self.date else {
            return ""
        }
        return humanReadableDateTimeFormatter.string(from: date)
    }

}
