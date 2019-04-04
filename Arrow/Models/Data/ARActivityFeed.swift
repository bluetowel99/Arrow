
import UIKit

struct ARActivityFeed {
    
    var voteCount: Int?
    var time: Date?
    var comment: String?
    var images = [URL]()
    var rating: ARPlaceRating?
    var createdBy: ARPerson?
    var name: String?
    var upvote: Bool?
    var isVoted: Bool = false
    var pk: String?
}

// MARK: - Dictionariable Implementation

extension ARActivityFeed: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var voteCount = "votecount"
        static var time = "time"
        static var rating = "rating"
        static var createdBy = "created_by"
        static var comment = "comment"
        static var images = "images"
        static var vote = "updownvote"
        static var pk = "pk"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        if let voteC = dictionary[Keys.voteCount] as? Int {
            voteCount = voteC
        }
        
        if let dateString = dictionary[Keys.time] as? String {
            if let result = serverDateFormatter.date(from: dateString) {
                time = result
            }
            else {
                time = iso8601CombinedDateTimeFormatter.date(from: dateString)
            }
        } else {
            time = Date()
        }
        if let commentS = dictionary[Keys.comment] as? String {
            comment = commentS
        }
        
        if let imageArry = dictionary[Keys.images] as? [[String: Any]] {
            for (_, element) in (imageArry.enumerated()) {
                let path = element["image"] as! String
                images.append(URL(string: path)!)
            }
        }
        
        if let createdByDict = dictionary[Keys.createdBy] as? [String: Any] {
            createdBy = ARPerson(with: createdByDict)
        }
        
        if let ratingArry = dictionary[Keys.rating] as? [[String: Any]] {
            for (_, element) in (ratingArry.enumerated()) {
                rating = ARPlaceRating(with: element)
            }
        }
        if let votes = dictionary[Keys.vote] as? [[String: Any]] {
            for (_, element) in (votes.enumerated()) {
                upvote = element["upvote"] as? Bool
                isVoted = true
            }
        }
        if let commentId = dictionary[Keys.pk] as? Int {
            pk = String(format: "%d", commentId)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        return [String: Any]()
    }
}
