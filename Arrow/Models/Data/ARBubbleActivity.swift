
import UIKit

enum ARBubbleActivityType: String {
    
    case bubbleCreation = "bubble creation"
    
    var title: String {
        switch self {
        case .bubbleCreation:
            return "Created bubble"
        }
    }
    
}

/// Arrow's Bubble Activity data model.
struct ARBubbleActivity {
    
    var type: ARBubbleActivityType
    var timeStamp: Date?
    
}

// MARK: - Dictionariable Implementation

extension ARBubbleActivity: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var type = "type"
        static var timeStamp = "time"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary,
            let typeRaw = dictionary[Keys.type] as? String,
            let type = ARBubbleActivityType(rawValue: typeRaw) else {
                return nil
        }
        
        self.type = type
        
        if let dateString = dictionary[Keys.timeStamp] as? String {
            timeStamp = ARConstants.Formatters.serverDateFormatter.date(from: dateString)
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        var dateString: String? = nil
        if let timeStamp = timeStamp {
            dateString = ARConstants.Formatters.serverDateFormatter.string(from: timeStamp)
        }
        
        let dict: [String: Any?] = [
            Keys.type: type.rawValue,
            Keys.timeStamp: dateString,
            ]
        return dict.nilsRemoved()
    }
    
}
