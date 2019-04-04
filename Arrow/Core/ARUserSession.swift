
import Foundation

struct ARUserSession {
    
    /// User authentication token.
    var authToken: String {
        didSet {
            authTokenLastUpdated = Date()
        }
    }
    
    /// User authetication token's last updated timestamp.
    fileprivate(set) var authTokenLastUpdated: Date = Date()
    
    /// Currently logged in user.
    var user: ARPerson?
    var checkIns: [ARCheckIn?] // TODO: Possibly move into ARPerson
    
    /// User's bubbles access point.
    lazy var bubbleStore = { ARBubbleStore() }()

    /// User's Thread store.
    lazy var threadStore = { ARMessageThreadStore() }()


    init(authToken: String) {
        self.authToken = authToken
        self.checkIns = []
    }
    
}

// MARK: - Dictionariable Implementation

extension ARUserSession: Dictionariable {
    
    enum Keys {
        static var authToken = "authToken"
        static var authTokenLastUpdated = "authTokenLastUpdated"
        static var user = "user"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let values = dictionary,
            let authToken = values[Keys.authToken] as? String,
            let authTokenLastUpdated = values[Keys.authTokenLastUpdated] as? Date else {
                return nil
        }
        
        self.authToken = authToken
        self.authTokenLastUpdated = authTokenLastUpdated
        user = ARPerson(with: values[Keys.user])
        checkIns = []
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.authToken: authToken,
            Keys.authTokenLastUpdated: authTokenLastUpdated,
            Keys.user: user?.dictionaryRepresentation(),
            ]
        return dict.nilsRemoved()
    }
    
}
