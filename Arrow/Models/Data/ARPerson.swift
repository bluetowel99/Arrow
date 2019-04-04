
import UIKit

/// Arrow's Person data model.
struct ARPerson {
    
    var identifier: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var litPoints: Int?
    var pictureUrl: URL?
    var thumbnail: UIImage?
    var batteryPercentage: Double?
    var isLocationSharingEnabled: Bool?
    var currentPosition: CLLocationCoordinate2D?
    
    func displayName(style: PersonNameComponentsFormatter.Style = .default) -> String? {
        var personNameComponents = PersonNameComponents()
        personNameComponents.givenName = firstName
        personNameComponents.familyName = lastName
        let personNameFormatter = PersonNameComponentsFormatter()
        personNameFormatter.style = style
        return personNameFormatter.string(from: personNameComponents)
    }
    
    init(identifier: String? = nil, firstName: String? = nil, lastName: String? = nil, email: String? = nil, phone: String? = nil, litPoints: Int? = nil, pictureUrl: URL? = nil, thumbnail: UIImage? = nil, position: CLLocationCoordinate2D? = nil) {
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        if(phone != nil)
        {
            self.phone = filteredPhone()
        }
        else
        {
            self.phone = phone
        }
        self.litPoints = litPoints
        self.pictureUrl = pictureUrl
        self.thumbnail = thumbnail
        self.currentPosition = position
        self.isLocationSharingEnabled = true
        self.batteryPercentage = 85
    }
    
    func filteredPhone() -> String! {
        if(phone == nil)
        {
            return "+05555555555"
        }
        
        let phoneNumberOnly = String(phone!.filter { "01234567890".contains($0) })
        
        var phoneStripped:String!
        if(phoneNumberOnly[phoneNumberOnly.startIndex] == "1") {
            phoneStripped = "+" + phoneNumberOnly
        } else {
            phoneStripped = "+1" + phoneNumberOnly
        }
        return phoneStripped
    }
    
    mutating func toggleLocationSharing()
    {
        isLocationSharingEnabled = !isLocationSharingEnabled!
    }
}

extension ARPerson: Equatable {
    static func == (lhs: ARPerson, rhs: ARPerson) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

// MARK: - Dictionariable Implementation

extension ARPerson: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var firstName = "first_name"
        static var lastName = "last_name"
        static var email = "email"
        static var phone = "mobile"
        static var litPoints = "lit_points"
        static var pictureUrl = "picture"
        static var location = "location"
        static var latitude = "latitude"
        static var longitude = "longitude"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        if let intId = dictionary[Keys.identifier] as? Int {
            identifier = String(intId)
        }
        firstName = dictionary[Keys.firstName] as? String
        lastName = dictionary[Keys.lastName] as? String
        email = dictionary[Keys.email] as? String
        phone = dictionary[Keys.phone] as? String
        litPoints = dictionary[Keys.litPoints] as? Int
        if let urlString = dictionary[Keys.pictureUrl] as? String {
            pictureUrl = URL(string: urlString)
        }
        let sublocationDictionary = dictionary[Keys.location] as? Dictionary<String, Any>
        if let latString = sublocationDictionary?[Keys.latitude] as? Double, let longString = sublocationDictionary?[Keys.longitude] as? Double {
            currentPosition = CLLocationCoordinate2D(latitude: latString, longitude: longString)
        }
        isLocationSharingEnabled = true
        batteryPercentage = 70
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.firstName: firstName,
            Keys.lastName: lastName,
            Keys.email: email,
            Keys.phone: phone,
            Keys.litPoints: litPoints,
            Keys.pictureUrl: pictureUrl?.absoluteString,
        ]
        return dict.nilsRemoved()
    }
    
}
