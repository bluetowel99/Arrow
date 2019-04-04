
import UIKit

enum ARMainTabItem: UInt {
    case map = 0
//    case messaging
//    case camera
    case search
    case profile
}

// MARK: - Core Properties

extension ARMainTabItem {
    
    var title: String? {
        return nil
    }
    
    var image: UIImage?  {
        switch self {
//        case .camera:
//            return R.image.cameraTabIcon()
        case .search:
            return R.image.searchTabIcon()
        case .profile:
            return R.image.profileTabIcon()
        case .map:
            return R.image.mapTabIcon()
//        case .messaging:
//            return R.image.messagingTabIcon()
        }
    }
    
    var selectedImage: UIImage? {
        switch self {
//        case .camera:
//            return nil
        case .profile:
            return R.image.profileTabIconSelected()
        case .search:
            return R.image.searchTabIconSelected()
        case .map:
            return R.image.mapTabIconSelected()
//        case .messaging:
//            return R.image.messagingTabIconSelected()
        }
    }
    
    var viewController: UIViewController? {
        switch self {
        case .map:
            return MapsVC.instantiate()
//        case .messaging:
//            return MessagingInboxVC.instantiate()
//        case .camera:
//            return CameraVC.instantiate()
        case .profile:
            return ProfileVC.instantiate()
        default:
            return SearchVC.instantiate()
        }
    }
    
    var isShownInTab: Bool {
        switch self {
//        case .camera:
//            return false
        default:
            return true
        }
    }
    
}
