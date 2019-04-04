
import Foundation

/// Arrow's Shared object info data model.
struct ARCheckIn {
    
    var placeId: String?
    var createdBy: ARPerson?
    var timeStamp: Date?
    
}

// MARK: - Dictionariable Implementation

extension ARCheckIn: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var createdBy = "user"
        static var placeId = "place"
        static var timeStamp = "time"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        placeId = dictionary[Keys.placeId] as? String
        createdBy = ARPerson(with: dictionary[Keys.createdBy] as? [String: Any])
        if let timeString = dictionary[Keys.timeStamp] as? String {
            timeStamp = ARConstants.Formatters.serverDateFormatter.date(from: timeString)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.placeId: placeId,
            Keys.createdBy: createdBy?.dictionaryRepresentation(),
            Keys.timeStamp: timeStamp,
            ]
        return dict.nilsRemoved()
    }
    
}
