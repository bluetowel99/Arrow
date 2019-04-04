
import UIKit

enum ARSearchDistanceFilter: UInt {
    case firstShortest = 0
    case secondShortest
    case thirdShortest
    case fourthShortest
    case fifthShortest
    
    var isInMetrics: Bool {
        return Locale.current.usesMetricSystem
    }
    
    var title: String? {
        switch self {
        case .firstShortest:
            return isInMetrics ? "3 km" : "2 mile"
        case .secondShortest:
            return isInMetrics ? "5 km" : "5 mile"
        case .thirdShortest:
            return isInMetrics ? "15 km" : "10 miles"
        case .fourthShortest:
            return isInMetrics ? "30 km" : "20 mile"
        case .fifthShortest:
            return isInMetrics ? "50 km" : "30 mile"
        }
    }
    
    /// All distances in Meters.
    var value: Int {
        switch self {
        case .firstShortest:
            return isInMetrics ? 3000 : 3219
        case .secondShortest:
            return isInMetrics ? 5000 : 8047
        case .thirdShortest:
            return isInMetrics ? 15000 : 16093
        case .fourthShortest:
            return isInMetrics ? 30000 : 32187
        case .fifthShortest:
            return isInMetrics ? 50000 : 48280
        }
    }
    
}
