
import UIKit

/// Arrow's Bubble data model.
struct ARBubble {
    
    var identifier: Int?
    var title: String
    var members: [ARPerson]?
    var meetings: [ARMeeting]?
    var picture: UIImage?
    var pictureUrl: URL?
    var recentActivity: ARBubbleActivity?
    
    
    init(identifier: Int? = nil, title: String, members: [ARPerson]? = nil, meetings: [ARMeeting]? = nil, picture: UIImage? = nil, pictureUrl: URL? = nil, recentActivity: ARBubbleActivity? = nil) {
        self.identifier = identifier
        self.title = title
        self.members = members
        self.meetings = meetings
        self.picture = picture
        self.pictureUrl = pictureUrl
        self.recentActivity = recentActivity
    }
}

// MARK: - Dictionariable Implementation

extension ARBubble: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var title = "title"
        static var pictureUrl = "picture"
        static var members = "members"
        static var meetings = "meetings"
        static var recentActivity = "recent_activity"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary,
            let title = dictionary[Keys.title] as? String else {
                return nil
        }
        
        // Identifier.
        identifier = dictionary[Keys.identifier] as? Int
        // Title.
        self.title = title
        // Picture URL.
        if let urlString = dictionary[Keys.pictureUrl] as? String,
            let url = URL(string: urlString) {
            pictureUrl = url
        }
        // Members.
        if let memdicts = dictionary[Keys.members] as? [Dictionary<String, Any>] {
            members = memdicts.flatMap { ARPerson(with: $0) }
        }
        // Meetings.
        if let meetdicts = dictionary[Keys.meetings] as? [Dictionary<String, Any>] {
            meetings = meetdicts.flatMap { ARMeeting(with: $0) }
        }
        // Recent Activity.
        if let activityDict = dictionary[Keys.recentActivity] as? [String: Any] {
            recentActivity = ARBubbleActivity(with: activityDict)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.title: title,
            Keys.pictureUrl: pictureUrl,
            Keys.members: members?.dictionaryRepresentation(),
            Keys.meetings: meetings?.dictionaryRepresentation(),
            ]
        return dict.nilsRemoved()
    }
    
}
