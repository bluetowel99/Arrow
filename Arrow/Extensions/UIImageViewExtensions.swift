
import AwesomeCache
import UIKit

// MARK: - Image Caching Extensions

extension UIImageView {
    
    /// Load, cache and set an image from url. Show placeholder image while loading.
    func setImage(from url: URL,
                  expiring: CacheExpiry = ARConstants.Cache.sharedImageCacheExpiry,
                  placeholder: UIImage? = nil, completion: (() -> Void)? = nil) {
        self.image = placeholder
        UIImage.load(from: url, expiring: expiring) { image in
            self.image = image
            completion?()
        }
    }

    /// Load, cache and set an image from url. Show placeholder image while loading.
    func setImage(from url: URL,
                  expiring: CacheExpiry = ARConstants.Cache.sharedImageCacheExpiry, key: String,
                  placeholder: UIImage? = nil, completion: (() -> Void)? = nil) {
        self.image = placeholder
        UIImage.load(from: url, expiring: expiring, key: key) { image in
            self.image = image
            completion?()
        }
    }

    func setImage(fromFirebaseUrl: URL, completion: (() -> Void)? = nil) {
        UIImage.load(fromFirebase: fromFirebaseUrl)  { image in
            self.image = image
            completion?()
        }

    }

}

// MARK: - Rotation Animation Extensions

extension UIImageView {
    
    func startInfiniteRotationAnimation() {
        layer.addInfiniteRotationAnimation()
    }
    
    func stopInfiniteRotationAnimation() {
        layer.removeInfiniteRotationAnimation()
    }
    
}
