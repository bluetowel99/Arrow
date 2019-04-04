
import AwesomeCache
import Foundation

struct ARConstants {
    
    enum AppEnvironment: String {
        case development = "DEV"
        case production = "PROD"
        case stage = "STAGE"
    }
    
    /// Dictionary of all Info.plist NRApp values.
    static var arrowAppInfoDict: Dictionary<String, AnyObject> {
        guard let appInfoDict = Bundle.main.infoDictionary?["ArrowApp"] as? Dictionary<String, AnyObject> else {
            assertionFailure("ArrowApp dictionary must be set in Info.plist")
            return Dictionary<String, AnyObject>()
        }
        
        return appInfoDict
    }
    
    /// App Environment set in Info.plist NRApp dictionary.
    static var appEnvironment: AppEnvironment {
        guard let appEnvironmentString = arrowAppInfoDict["App Environment"] as? String,
            let appEnvironment = AppEnvironment(rawValue: appEnvironmentString.uppercased()) else {
                assertionFailure("Incorrect App Environment value in Info.plist")
                return AppEnvironment.development
        }
        
        return appEnvironment
    }
    
}

// MARK: - Formatters

extension ARConstants {
    
    struct Formatters {
        
        static let serverDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter
        }()
    }
    
}

// MARK: -  ARConstant Grouped Struct Definitions

extension ARConstants {
    
    static let ACTIVITY_FEED_COUNT: Int = 5
    struct Cache {
        
        static let sharedImageCacheName = "ARROW_SHARED_IMAGE_CACHE"
        static var sharedImageCacheExpiry: CacheExpiry {
            get {
                return .never
            }
        }
    }
    
    struct FormValidation {
        static let minPasswordLength = 6
    }
    
    struct Keychain {
        static let isUserLoggedIn = "AR_IS_USER_LOGGED_IN"
        static let userSession = "AR_USER_SESSION"
    }
    
    struct ImageView {
        static let seperation: CGFloat = 3.0
        static let halfWidth: CGFloat = 1 / 2
        static let moreHalfWidth: CGFloat = 3 / 5
        static let lessHalfWidth: CGFloat = 2 / 5
        static let moreHeight: CGFloat = 5 / 12
    }
    
    struct Notification {
        static let ACTIVITY_FEED: String = "ACTIVITY_FEED"
    }
    
    struct URLs {

        /// App backend's base URL.
        static var base: URL {
            switch appEnvironment {
            case .development:
                return URL(string: "https://shielded-island-20534.herokuapp.com/")!
            case .production:
                assertionFailure("PROD base URL not set.")
                return URL(string: "")!  // TODO(kia): Add PROD base url.
            case .stage:
                assertionFailure("STAGE base URL not set.")
                return URL(string: "")!  // TODO(kia: Add STAGE base url.
            }
        }
        
    }

    struct GooglePlace {
        static var key = "AIzaSyC1pS4ODbUKT_wag8aapVA4ioVYM0ya8oA"
    }
    
}
