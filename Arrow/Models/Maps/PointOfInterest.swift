
import CoreLocation
import UIKit

enum LitLevel: String {
    case dead
    case prettyChill
    case decentScene
    case veryLively
    case lit
    
    func color() -> UIColor {
        switch self {
        case .dead:
            return R.color.arrowColors.waterBlue()
        case .prettyChill:
            return R.color.arrowColors.oceanBlue()
        case .decentScene:
            return R.color.arrowColors.marineBlue()
        case .veryLively:
            return UIColor(red: 255.0 / 255.0, green: 163.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.75)
        case .lit:
            return UIColor(red: 255.0 / 255.0, green: 89.0 / 255.0, blue: 13.0 / 255.0, alpha: 0.75)
        }
    }
}

enum POIType: String {
    case bar
    case gym
    case media
    case movieTheater
    case outdoorRecreation
    case restaurant
}

struct PointOfInterest {
    let position: CLLocationCoordinate2D
    let name: String
    let encodedPaths: String?
    let level: LitLevel
    let type: POIType
}

// MARK: - Dictionariable Implementation

extension PointOfInterest: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var latitude = "latitude"
        static var longitude = "longitude"
        static var name = "name"
        static var encodedPaths = "encodedPaths"
        static var level = "level"
        static var type = "type"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        let latitude = dictionary[Keys.latitude] as! CLLocationDegrees
        let longitude = dictionary[Keys.longitude] as! CLLocationDegrees
        position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        name = (dictionary[Keys.name] as? String)!
        encodedPaths = dictionary[Keys.encodedPaths] as? String
        
        if let levelString = dictionary[Keys.level] as? String {
            level = LitLevel(rawValue: levelString)!
        } else {
            level = .dead
        }
        
        if let typeString = dictionary[Keys.type] as? String {
            type = POIType(rawValue: typeString)!
        } else {
            type = .bar
        }
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        return [String: Any]()
    }

}
