
import UIKit

enum ARMainCategory: UInt, ARSearchCategory {
    case restaurants = 0
    case nightlife
    case more
    
    var tintColor: UIColor {
        switch self {
        case .more:
            return R.color.arrowColors.grassGreen()
        case .nightlife:
            return R.color.arrowColors.indigo()
        case .restaurants:
            return R.color.arrowColors.waterBlue()
        }
    }
    
    var title: String? {
        switch self {
        case .more:
            return "More"
        case .nightlife:
            return "Nightlife"
        case .restaurants:
            return "Restaurants"
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .more:
            return nil
        case .nightlife:
            return "Nightlife"
        case .restaurants:
            return "Restaurants"
        }
    }
    
    var searchQuery: String? {
        switch self {
        case .more:
            return nil
        case .nightlife:
            return "nightlife"
        case .restaurants:
            return "restaurants"
        }
    }
    
    func image(inBW: Bool) -> UIImage? {
        switch self {
        case .more:
            return inBW ? R.image.more_bw() : R.image.more()
        case .nightlife:
            return inBW ? R.image.nightlife_bw() : R.image.nightlife()
        case .restaurants:
            return inBW ? R.image.restaurants_bw() : R.image.restaurants()
        }
    }
    
    var allSubCategories: [ARSearchCategory] {
        switch self {
        case .more:
            return ARMoreCategory.allValues
        case .nightlife:
            return ARNightlifeCategory.allValues
        case .restaurants:
            return ARRestaurantCategory.allValues
        }
    }
    
}
