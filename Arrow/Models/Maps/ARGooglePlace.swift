
import UIKit
import CoreLocation

enum ARGooglePlaceType: String {
    case bar = "bar"
    case gym = "gym"
    case movieTheater = "movie_theater"
    case outdoorRecreation = "park"
    case restaurant = "restaurant"
    
    static let allValues = [bar, gym, movieTheater, outdoorRecreation, restaurant]
    
    var displayName: String {
        switch self {
        case .bar:
            return "Bar"
        case .gym:
            return "Gym"
        case .movieTheater:
            return "Movie Theater"
        case .outdoorRecreation:
            return "Park"
        case .restaurant:
            return "Restaurant"
        }
    }
}

// MARK: - ARGooglePlace

struct ARGooglePlace {
    
    var placeId: String
    var latitude : CLLocationDegrees
    var longitude : CLLocationDegrees
    var name : String?
    var priceLevel : Int?
    var rating: Float?
    var website: String?
    var photos: [ARGooglePlacePhoto]?
    var phone: String?
    var address: String?
    var types: [ARGooglePlaceType]?
    var openingHours: [String: Any]?
    var isBookmarked: Bool
    var isCheckedIn: Bool
    var checkIns: [ARPerson]?
    var litMeterEnabled: Bool?
    var litMeter: Float?
    var moreInformation: [String: Any]?
    var specials: [[String: Any]]?
    
    var topComments: [[String: Any]]?
    var latestComments: [[String: Any]]?

    var arRating: ARPlaceRating?
}

extension ARGooglePlace: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var placeId = "place_id"
        static var googlePlaceId = "google_place_id"
        static var latitude = "lat"
        static var longitude = "lng"
        static var name = "name"
        static var priceLevel = "price_level"
        static var rating = "rating"
        static var website = "website"
        static var photos = "photos"
        static var phone = "formatted_phone_number"
        static var address = "vicinity"
        static var types = "types"
        static var openingHours = "opening_hours"
        static var isBookmarked = "bookmarked"
        static var isCheckedIn = "checked_in"
        static var checkIns = "check_ins"
        static var user = "user"
        static var litMeterEnabled = "lit_meter_enabled"
        static var litMeter = "lit_meter"
        static var moreInformation = "more_info"
        static var specials = "specials"
        static var topComments = "top_comments"
        static var latestComments = "latest_comments"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary, let id = dictionary[Keys.placeId] as? String else {
            return nil
        }
        
        guard let geometry = dictionary["geometry"] as? [String: Any],
            let location = geometry["location"] as? [String: Any] else {
                return nil
        }
        
        placeId = id
        latitude = location[Keys.latitude] as? CLLocationDegrees ?? 0.0
        longitude = location[Keys.longitude] as? CLLocationDegrees ?? 0.0
        name = (dictionary[Keys.name] as? String)!
        priceLevel = dictionary[Keys.priceLevel] as? Int
        rating = dictionary[Keys.rating] as? Float
        website = dictionary[Keys.website] as? String

        arRating = ARPlaceRating(with: dictionary[Keys.rating] as? Dictionary<String, Any>)

        // Replace google rating with Arrow rating if POI has been rated
        if let atmosphere = self.arRating?.atmosphere, let service = self.arRating?.service,
            let food = self.arRating?.food, let experience = self.arRating?.experience,
            atmosphere > 0, service > 0, food > 0, experience > 0 {

            var sum = atmosphere
            sum += experience
            sum += food
            sum += service
            rating = sum / 4.0
        }
        
        // Photos
        if let dicts = dictionary[Keys.photos] as? [Dictionary<String, Any>] {
            photos = dicts.flatMap { ARGooglePlacePhoto(with: $0) }
        }
        
        phone = dictionary[Keys.phone] as? String
        address = dictionary[Keys.address] as? String
        if let googleTypes = dictionary[Keys.types] as? [String] {
            types = googleTypes.flatMap { ARGooglePlaceType(rawValue: $0) }
        }
        openingHours = dictionary[Keys.openingHours] as? [String: Any]
        moreInformation = dictionary[Keys.moreInformation] as? [String: Any]
        specials = dictionary[Keys.specials] as? [[String: Any]]
        topComments = dictionary[Keys.topComments] as? [[String: Any]]
        latestComments = dictionary[Keys.latestComments] as? [[String: Any]]
        isBookmarked = dictionary[Keys.isBookmarked] as? Bool ?? false
        isCheckedIn = dictionary[Keys.isCheckedIn] as? Bool ?? false
        
        // Check-Ins
        if let checkInUsers = dictionary[Keys.checkIns] as? [Any] {
            checkIns = [ARPerson]()
            for object in checkInUsers {
                if let checkInField = object as? Dictionary<String, Any> {
                    for (key, data) in checkInField {
                        if(key == Keys.user) {
                            checkIns!.append(ARPerson(with: data)!)
                        }
                    }
                }
            }
        }
        
        if(dictionary[Keys.litMeterEnabled] != nil) {
            litMeterEnabled = dictionary[Keys.litMeterEnabled] as? Bool ?? false
            litMeter = dictionary[Keys.litMeter] as? Float
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        return [String: Any]()
    }
    
    func getClosingTime(for date: Date = Date()) -> String? {
        guard let openingHours = self.openingHours else {
            print("NO opening hours")
            return nil
        }
        
        func extractClosingTime() -> String? {
            // Get day of the week.
            let day = Calendar(identifier: .gregorian).component(.weekday, from: date)
            guard let periods = openingHours["periods"] as? [[String: Any]],
                periods.count > day,
                let close = periods[day]["close"] as? [String: Any] else {
                    return nil
            }
            
            if let time = close["time"] as? Int {
                return String(time)
            } else if let time = close["time"] as? String {
                return time
            }
            return nil
        }
        
        if let time = extractClosingTime(),
            let dateTime = plainHourFormatter.date(from: time) {
            return hourFormatter.string(from: dateTime)
        }
        
        return nil
    }
}

extension ARGooglePlace: Equatable {}

func == (lhs: ARGooglePlace, rhs: ARGooglePlace) -> Bool {
    return lhs.placeId == rhs.placeId
}

extension ARGooglePlace: Hashable {
    var hashValue: Int {
        return placeId.hashValue
    }
}


// MARK: - ARGooglePlacePhoto

struct ARGooglePlacePhoto {
    
    var url: URL?
    var height: Int
    var width: Int
    
}

extension ARGooglePlacePhoto: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var photoReference = "photo_reference"
        static var height = "height"
        static var width = "width"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        height = dictionary[Keys.height] as? Int ?? 0
        width = dictionary[Keys.width] as? Int ?? 0
        
        if let reference = dictionary[Keys.photoReference] as? String {
            url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(width)&photoreference=\(reference)&key=\(ARConstants.GooglePlace.key)")
        }
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        return [String: Any]()
    }
    
}

extension ARGooglePlace {

    mutating func copyNonNilData(newPOI: ARGooglePlace) {
        if let newPriceLevel = newPOI.priceLevel {
            priceLevel = newPriceLevel
        }

        if let newRating = newPOI.rating {
            rating = newRating
        }

        if let newWebsite = newPOI.website {
            website = newWebsite
        }

        if let newRating = newPOI.arRating {
            arRating = newRating
        }

        // Replace google rating with Arrow rating if POI has been rated
        if let atmosphere = newPOI.arRating?.atmosphere, let service = newPOI.arRating?.service,
           let food = newPOI.arRating?.food, let experience = newPOI.arRating?.experience,
           atmosphere > 0, service > 0, food > 0, experience > 0 {

            var sum = atmosphere
            sum += experience
            sum += food
            sum += service
            rating = sum / 4.0
        }

        if let newPhone = newPOI.phone {
            phone = newPhone
        }

        if let newAddress = newPOI.address {
            address = newAddress
        }

        if let newOpeningHours = newPOI.openingHours {
            openingHours = newOpeningHours
        }
        
        if let newInformation = newPOI.moreInformation {
            moreInformation = newInformation
        }
        
        if let newSpecials = newPOI.specials {
            specials = newSpecials
        }
        
        if let newTopComments = newPOI.topComments {
            topComments = newTopComments
        }
        
        if let newLatestComments = newPOI.latestComments {
            latestComments = newLatestComments
        }

        isBookmarked = isBookmarked ? isBookmarked : newPOI.isBookmarked
        isCheckedIn = isCheckedIn ? isCheckedIn : newPOI.isCheckedIn
    }
}
