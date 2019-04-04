
import UIKit

/// Arrow's Settings Visibility values.
enum ARSettingVisibility: String {
    case arrowFriends = "Arrow Friends"
    case bubbleMembers = "Bubble Members"
    case everyone = "Everyone"
}

/// Arrow's Settings data model.
struct ARSettings {
    
    var profileVisibility: ARSettingVisibility?
    var litMeterNotification: ARSettingVisibility?
    var placeRatingNotification: ARSettingVisibility?
    var activityFeedNotification: ARSettingVisibility?
    var dealsNotification: Bool?
    
    init(profileVisibility: ARSettingVisibility? = nil, litMeterNotification: ARSettingVisibility? = nil, placeRatingNotification: ARSettingVisibility? = nil, activityFeedNotification: ARSettingVisibility? = nil, dealsNotification: Bool? = nil) {
        self.profileVisibility = profileVisibility
        self.litMeterNotification = litMeterNotification
        self.placeRatingNotification = placeRatingNotification
        self.activityFeedNotification = activityFeedNotification
        self.dealsNotification = dealsNotification
    }
    
}

// MARK: - Dictionariable Implementation

extension ARSettings: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var profileVisibility = "see_profile"
        static var litMeterNotification = "lit_meter_from"
        static var placeRatingNotification = "rating_from"
        static var activityFeedNotification = "posts_from"
        static var dealsNotification = "get_deals"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        profileVisibility = ARSettingVisibility(rawValue: dictionary[Keys.profileVisibility] as? String)
        litMeterNotification = ARSettingVisibility(rawValue: dictionary[Keys.litMeterNotification] as? String)
        placeRatingNotification = ARSettingVisibility(rawValue: dictionary[Keys.placeRatingNotification] as? String)
        activityFeedNotification = ARSettingVisibility(rawValue: dictionary[Keys.activityFeedNotification] as? String)
        dealsNotification = dictionary[Keys.dealsNotification] as? Bool
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.profileVisibility: profileVisibility?.rawValue,
            Keys.litMeterNotification: litMeterNotification?.rawValue,
            Keys.placeRatingNotification: placeRatingNotification?.rawValue,
            Keys.activityFeedNotification: activityFeedNotification?.rawValue,
            Keys.dealsNotification: dealsNotification,
        ]
        return dict.nilsRemoved()
    }
    
}
