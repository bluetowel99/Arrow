
import UIKit

public enum ARMessageThreadType: Int {
    case bubble = 1
    case direct = 2
    case group = 3
}

struct ARMessageThread {

    var identifier : Int?
    var type: ARMessageThreadType
    var title: String?
    var previewText: String?
    var date: Date?
    var bubble: ARBubble?
    var isUnread: Bool?
    var imageURL: URL?
}

// MARK: - Dictionariable Implementation

extension ARMessageThread: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var title = "title"
        static var previewText = "previewText"
        static var date = "date"
        static var type = "type"
        static var isUnread = "isUnread"
        static var bubble = "bubble"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        if let typeString = dictionary[Keys.type] as? Int {
            type = ARMessageThreadType(rawValue: typeString)!
        } else {
            type = .direct
        }
        identifier = dictionary[Keys.identifier] as? Int

        title = dictionary[Keys.title] as? String
        previewText = dictionary[Keys.previewText] as? String
        
        if let dateString = dictionary[Keys.date] as? String {
            date = iso8601CombinedDateTimeFormatter.date(from: dateString)
        } else {
            date = Date()
        }
        
        if let typeString = dictionary[Keys.type] as? Int {
            type = ARMessageThreadType(rawValue: typeString)!
        } else {
            type = .direct
        }

        if let bubbleDict = dictionary[Keys.bubble] as? [String: Any] {
            bubble = ARBubble(with: bubbleDict)
        }
        
        isUnread = dictionary[Keys.isUnread] as? Bool

        switch type {
        case .bubble:
           title = bubble?.title
           imageURL = bubble?.pictureUrl
            break
        case .group:
            break
        case .direct:
            break
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        return [String: Any]()
    }
    
}
