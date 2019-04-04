
import UIKit

enum ARSearchSortFilter: UInt {
    case bestMatch = 0
    case distance
    
    var title: String? {
        switch self {
        case .bestMatch:
            return "Best Match"
        case .distance:
            return "Distance"
        }
    }
    
    var value: ARGooglePlaceRank {
        switch self {
        case .bestMatch:
            return .prominence
        case .distance:
            return .distance
        }
    }
    
}
