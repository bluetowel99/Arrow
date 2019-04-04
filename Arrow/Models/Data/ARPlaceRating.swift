
import Foundation

/// Arrow's Shared object info data model.
struct ARPlaceRating {
    
    var atmosphere: Float? = 0
    var experience: Float? = 0
    var food: Float? = 0
    var service: Float? = 0
}

// MARK: - Dictionariable Implementation

extension ARPlaceRating: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var atmosphere = "atmosphere"
        static var experience = "experience"
        static var food = "food"
        static var service = "service"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        atmosphere = dictionary[Keys.atmosphere] as? Float
        experience = dictionary[Keys.experience] as? Float
        food = dictionary[Keys.food] as? Float
        service = dictionary[Keys.service] as? Float
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.atmosphere: atmosphere,
            Keys.experience: experience,
            Keys.food: food,
            Keys.service: service,
            ]
        return dict.nilsRemoved()
    }

    mutating func setRatingOnType(ratingType: ARPlaceRating.Key, rating: Float) {
        if ARPlaceRating.Keys.experience == ratingType {
            experience = rating
        } else if ARPlaceRating.Keys.food == ratingType {
            food = rating
        } else if ARPlaceRating.Keys.atmosphere == ratingType {
            atmosphere = rating
        } else if ARPlaceRating.Keys.service == ratingType {
            service = rating
        }
    }
}
