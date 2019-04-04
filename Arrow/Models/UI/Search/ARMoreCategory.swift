
import UIKit

enum ARMoreCategory: UInt, ARSearchCategory {
    case gyms = 0
    case outdoorRec
    case malls
    case movies
    case amusement
    case theatre
    
    var tintColor: UIColor { return R.color.arrowColors.grassGreen() }
    
    var title: String? {
        switch self {
        case .amusement:
            return "Amusement"
        case .gyms:
            return "Gyms"
        case .malls:
            return "Malls"
        case .movies:
            return "Movies"
        case .outdoorRec:
            return "Outdoor Rec"
        case .theatre:
            return "Theatre"
        }
    }
    
    var headerTitle: String? {
        switch self {
        case .amusement:
            return "Amusement Parks"
        case .gyms:
            return "Gyms"
        case .malls:
            return "Malls"
        case .movies:
            return "Movie Theatres"
        case .outdoorRec:
            return "Outdoor Recreation"
        case .theatre:
            return "Theatres"
        }
    }
    
    var searchQuery: String? {
        switch self {
        case .amusement:
            return "amusement park"
        case .gyms:
            return "gym"
        case .malls:
            return "shopping mall"
        case .movies:
            return "movie theatre"
        case .outdoorRec:
            return "outdoor recreation"
        case .theatre:
            return "theatre"
        }
    }
    
    func image(inBW: Bool) -> UIImage? {
        switch self {
        case .amusement:
            return inBW ? R.image.amusement_bw() : R.image.amusement()
        case .gyms:
            return inBW ? R.image.gym_bw() : R.image.gym()
        case .malls:
            return inBW ? R.image.mall_bw() : R.image.mall()
        case .movies:
            return inBW ? R.image.movies_bw() : R.image.movies()
        case .outdoorRec:
            return inBW ? R.image.outdoor_bw() : R.image.outdoor()
        case .theatre:
            return inBW ? R.image.theater_bw() : R.image.theater()
        }
    }
}
