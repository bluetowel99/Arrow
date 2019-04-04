
import UIKit

enum ARNightlifeCategory: UInt, ARSearchCategory {
    case bars = 0
    case clubs
    case liveMusic
    case mostLit
    
    var tintColor: UIColor { return R.color.arrowColors.indigo() }
    
    var title: String? {
        switch self {
        case .bars:
            return "Bars"
        case .clubs:
            return "Clubs"
        case .liveMusic:
            return "Live Music"
        case .mostLit:
            return "Most Lit"
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .bars:
            return "Bars"
        case .clubs:
            return "Clubs"
        case .liveMusic:
            return "Live Music"
        case .mostLit:
            return "Most Lit Nightlife"
        }
    }
    
    var searchQuery: String? {
        switch self {
        case .bars:
            return "bar"
        case .clubs:
            return "night club"
        case .liveMusic:
            return "live music"
        case .mostLit:
            return "most popular bar club"
        }
    }
    
    func image(inBW: Bool) -> UIImage? {
        switch self {
        case .bars:
            return inBW ? R.image.bars_bw() : R.image.bars()
        case .clubs:
            return inBW ? R.image.clubs_bw() : R.image.clubs()
        case .liveMusic:
            return inBW ? R.image.liveMusic_bw() : R.image.liveMusic()
        case .mostLit:
            return inBW ? R.image.mostLit_bw() : R.image.mostLit()
        }
    }
}
