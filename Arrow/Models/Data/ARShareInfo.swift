
import Foundation

/// Arrow's Shared object info data model.
struct ARShareInfo {
    
    var bubbleIds = [String]()
    var pendingIds = [String]()
    var userIds = [String]()
    
}

// MARK: - Dictionariable Implementation

extension ARShareInfo: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var bubbleIds = "bubbles"
        static var pendingIds = "pendings"
        static var userIds = "users"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        bubbleIds = dictionary[Keys.bubbleIds] as? [String] ?? [String]()
        pendingIds = dictionary[Keys.pendingIds] as? [String] ?? [String]()
        userIds = dictionary[Keys.userIds] as? [String] ?? [String]()
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.bubbleIds: bubbleIds,
            Keys.pendingIds: pendingIds,
            Keys.userIds: userIds,
            ]
        return dict.nilsRemoved()
    }
    
}
