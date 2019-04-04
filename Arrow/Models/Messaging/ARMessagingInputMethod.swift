
import UIKit

enum ARMessagingInputMethod: UInt {
    case camera = 0
    case gallery
    case location
    case poll
    case voice
}

// MARK: - Core Properties

extension ARMessagingInputMethod {
    
    var image: UIImage?  {
        switch self {
        case .camera:
            return R.image.messagingCameraIcon()
        case .gallery:
            return R.image.messagingGalleryIcon()
        case .location:
            return R.image.messagingLocationIcon()
        case .poll:
            return R.image.messagingPollIcon()
        case .voice:
            return R.image.messagingVoiceIcon()
        }
    }
    
    static var tintColor: UIColor {
        return R.color.arrowColors.hathiGray()
    }
    
    static var selectedTintColor: UIColor {
        return R.color.arrowColors.waterBlue()
    }
    
}
