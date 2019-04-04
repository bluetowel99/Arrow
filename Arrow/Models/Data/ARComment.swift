
import Foundation

/// Arrow's Shared object info data model.
struct ARComment {
    
    var id: Int?
    var createdBy: ARPerson?
    var text: String?
    var timeStamp: Date?
    
}

// MARK: - Dictionariable Implementation

extension ARComment: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var id = "id"
        static var createdBy = "created_by"
        static var text = "comment"
        static var timeStamp = "time"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        id = dictionary[Keys.id] as? Int
        createdBy = ARPerson(with: dictionary[Keys.createdBy] as? [String: Any])
        text = dictionary[Keys.text] as? String
        if let timeString = dictionary[Keys.timeStamp] as? String {
            timeStamp = ARConstants.Formatters.serverDateFormatter.date(from: timeString)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.id: id,
            Keys.createdBy: createdBy?.dictionaryRepresentation(),
            Keys.text: text,
            Keys.timeStamp: timeStamp,
            ]
        return dict.nilsRemoved()
    }
    
}
