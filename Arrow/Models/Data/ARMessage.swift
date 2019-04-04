
import UIKit

enum ARMessageType: String {
    case text = "text"
    case audio = "audio"
    case location = "location"
    case media = "media"
    case poll = "poll"
}

enum ARMessageMediaType: String {
    case image = "image"
    case video = "audio"
    case option = "option"
}

struct ARMessage {

    var identifier: String?
    var senderId: String?
    var displayName: String?
    var text: String?
    var pictureUrl: URL?
    var date: Date?
    var type: ARMessageType
    var media: [ARMessageMedia]?
    var question: String?
    var options: [ARMessageMedia]?
    var isBeingEdited: Bool?
    var newImage: UIImage?
    var placeName: String?
    var placeAddress: String?
    var lat: Float?
    var lng: Float?
    var audioUrl: URL?
    var timestamp: Date?
    var likes: [String: AnyObject]?
}

// MARK: - Dictionariable Implementation

extension ARMessage: Dictionariable {

    /// Dictionary keys.
    struct Keys {
        static var identifier = "identifier"
        static var senderId = "id"
        static var displayName = "displayName"
        static var text = "text"
        static var pictureUrl = "picture"
        static var audioUrl = "audioUrl"
        static var date = "date"
        static var type = "type"
        static var media = "media"
        static var question = "question"
        static var options = "options"
        static var placeAddress = "address"
        static var lat = "lat"
        static var lng = "lng"
        static var timestamp = "timestamp"
        static var likes = "likes"

    }

    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary, let typeString = dictionary[Keys.type] as? String, let type = ARMessageType(rawValue: typeString) else {
                return nil
        }
        // Identifier.
        self.identifier = dictionary[Keys.identifier] as? String
        // Title.
        self.text = dictionary[Keys.text] as? String
        self.senderId = dictionary[Keys.senderId] as? String
        self.displayName = dictionary[Keys.displayName] as? String

        // Picture URL.
        if let urlString = dictionary[Keys.pictureUrl] as? String,
            let url = URL(string: urlString) {
            pictureUrl = url
        }
        if let dateString = dictionary[Keys.date] as? String {
            self.date = iso8601CombinedDateTimeFormatter.date(from: dateString)
        }
        self.type = type

        // media
        if let dict = dictionary[Keys.media] as? Dictionary<String, Any> {
            media = dict.flatMap { ARMessageMedia(with: $1) }
        }

        question = dictionary[Keys.question] as? String

        // options
        if let dict = dictionary[Keys.options] as? Dictionary<String, Any> {
            options = dict.flatMap { ARMessageMedia(with: $1) }
        }

        placeAddress = dictionary[Keys.placeAddress] as? String
        lat = dictionary[Keys.lat] as? Float
        lng = dictionary[Keys.lng] as? Float

        if let urlString = dictionary[Keys.audioUrl] as? String,
            let url = URL(string: urlString) {
            audioUrl = url
        }
        if let timestampNumber = dictionary[Keys.timestamp] as? Double {
            timestamp = Date(timeIntervalSince1970: timestampNumber / 1000)
        }

        likes = dictionary[Keys.likes] as? [String: AnyObject]
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.text: text,
            Keys.pictureUrl: pictureUrl?.absoluteString,
            ]
        return dict.nilsRemoved()
    }


}

// MARK: - ARMessageMedia

struct ARMessageMedia {

    var identifier: String?
    var type: ARMessageMediaType
    var previewImageUrl: URL?
    var url: URL?
    var caption: String?
    var text: String?
    var votes: [String: AnyObject]?
    var address: String?
    var placeName: String?

}

extension ARMessageMedia: Dictionariable {

    /// Dictionary keys.
    struct Keys {
        static var identifier = "identifier"
        static var type = "type"
        static var previewImageUrl = "previewImageUrl"
        static var url = "url"
        static var caption = "caption"
        static var text = "text"
        static var votes = "votes"
        static var address = "address"
        static var placeName = "placeName"
    }

    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary, let typeString = dictionary[Keys.type] as? String, let type =  ARMessageMediaType(rawValue: typeString) else {
            return nil
        }
        self.type = type

        if let urlString = dictionary[Keys.url] as? String {
            url = URL(string: urlString)
        }
        text = dictionary[Keys.text] as? String
        identifier = dictionary[Keys.identifier] as? String
        votes = dictionary[Keys.votes] as? [String: AnyObject]
        placeName = dictionary[Keys.placeName] as? String
        address = dictionary[Keys.address] as? String
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.type: type.rawValue,
            Keys.previewImageUrl: "",
            Keys.url: url?.absoluteString,
            ]
        return dict.nilsRemoved()
    }

}
