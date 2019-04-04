
import Foundation

/// Arrow's Bookmark object info data model.
struct ARBookmark {
    
    var place: ARGooglePlace?
    var createdBy: ARPerson?
    var timeStamp: Date?
    
}

// MARK: - Dictionariable Implementation

extension ARBookmark: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var createdBy = "user"
        static var place = "place"
        static var timeStamp = "time"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        place = ARGooglePlace(with: dictionary[Keys.place] as? [String: Any])
        createdBy = ARPerson(with: dictionary[Keys.createdBy] as? [String: Any])
        if let timeString = dictionary[Keys.timeStamp] as? String {
            timeStamp = ARConstants.Formatters.serverDateFormatter.date(from: timeString)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.place: place?.placeId,
            Keys.createdBy: createdBy?.dictionaryRepresentation(),
            Keys.timeStamp: timeStamp,
            ]
        return dict.nilsRemoved()
    }
    
}
