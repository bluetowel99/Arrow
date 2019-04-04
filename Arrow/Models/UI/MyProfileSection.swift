
import Foundation

enum MyProfileSection: UInt {
    
    case info = 0
    case actions = 1
//    case media = 2
    case currentLocation = 2// = 3
//    case locationShares = 4
    case checkIns = 3// = 5
    
    var title: String? {
        switch self {
        case .actions, .info:
            return nil
        case .checkIns:
            return "Recent Check-Ins"
        case .currentLocation:
            return "My Location"
//        case .locationShares:
//            return "Shared With"
//        case .media:
//            return "Media"
        }
    }
    
    var hasSeparatorLine: Bool {
        switch self {
        case .actions, .info://, .locationShares:
            return false
        case .checkIns, .currentLocation://, .media:
            return true
        }
    }
    
    var canShowMore: Bool {
        switch self {
        case .actions, .info, .currentLocation:
            return false
        case .checkIns://, .locationShares, .media:
            return true
        }
    }
    
}
