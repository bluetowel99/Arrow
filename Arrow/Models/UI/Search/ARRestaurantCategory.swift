
import UIKit

enum ARRestaurantCategory: UInt, ARSearchCategory {
    case pizza = 0
    case burger
    case italian
    case chinese
    case mexican
    case breakfast
    case healthy
    case sushi
    case thai
    case steakhouse
    case sandwich
    case japanese
    case vegetarian
    case seafood
    case indian
    case vietnamese
    
    var tintColor: UIColor { return R.color.arrowColors.waterBlue() }
    
    var title: String? {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .burger:
            return "Burger"
        case .chinese:
            return "Chinese"
        case .healthy:
            return "Healthy"
        case .indian:
            return "Indian"
        case .italian:
            return "Italian"
        case .japanese:
            return "Japanese"
        case .mexican:
            return "Mexican"
        case .pizza:
            return "Pizza"
        case .sandwich:
            return "Sandwich"
        case .seafood:
            return "Seafood"
        case .steakhouse:
            return "Steakhouse"
        case .sushi:
            return "Sushi"
        case .thai:
            return "Thai"
        case .vegetarian:
            return "Vegetarian"
        case .vietnamese:
            return "Vietnamese"
        }
    }
    
    var headerTitle: String? {
        if let title = title {
            return title + " Restaurants"
        }
        
        return nil
    }
    
    var searchQuery: String? {
        if let title = title {
            return title + " restaurant"
        }
        
        return nil
    }
    
    func image(inBW: Bool) -> UIImage? {
        switch self {
        case .breakfast:
            return inBW ? R.image.breakfast_bw() : R.image.breakfast()
        case .burger:
            return inBW ? R.image.burgers_bw() : R.image.burgers()
        case .chinese:
            return inBW ? R.image.chinese_bw() : R.image.chinese()
        case .healthy:
            return inBW ? R.image.healthy_bw() : R.image.healthy()
        case .indian:
            return inBW ? R.image.indian_bw() : R.image.indian()
        case .italian:
            return inBW ? R.image.italian_bw() : R.image.italian()
        case .japanese:
            return inBW ? R.image.japanese_bw() : R.image.japanese()
        case .mexican:
            return inBW ? R.image.mexican_bw() : R.image.mexican()
        case .pizza:
            return inBW ? R.image.pizza_bw() : R.image.pizza()
        case .sandwich:
            return inBW ? R.image.sandwich_bw() : R.image.sandwich()
        case .seafood:
            return inBW ? R.image.seafood_bw() : R.image.seafood()
        case .steakhouse:
            return inBW ? R.image.steakhouse_bw() : R.image.steakhouse()
        case .sushi:
            return inBW ? R.image.sushi_bw() : R.image.sushi()
        case .thai:
            return inBW ? R.image.thai_bw() : R.image.thai()
        case .vegetarian:
            return inBW ? R.image.vegetarian_bw() : R.image.vegetarian()
        case .vietnamese:
            return inBW ? R.image.vietnamese_bw() : R.image.vietnamese()
        }
    }
}
