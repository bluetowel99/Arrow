
import AwesomeCache
import UIKit
import FirebaseStorage

// MARK: - Image Caching Extensions

extension UIImage {
    
    typealias ImageCacheCompletion = (UIImage) -> Void
    
    /// UIImage shared cache.
    static var sharedCache: Cache<UIImage>? = {
        do {
            return try Cache<UIImage>(name: ARConstants.Cache.sharedImageCacheName)
        } catch let error {
            print("Error initialing platform's shared cache:")
            print(error)
            return nil
        }
    }()
    
    /// Load image async from a url via a completion block.
    static func load(from url: URL,
                     expiring: CacheExpiry = ARConstants.Cache.sharedImageCacheExpiry,
                     completion: @escaping ImageCacheCompletion) {
        // First, check the cache.
        if let image = cachedImage(forKey: url.absoluteString) {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        // Download if not found in the cache.
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image from url: \(url.absoluteString)")
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data from url: \(url.absoluteString)")
                return
            }
            
            UIImage.sharedCache?.setObject(image, forKey: url.absoluteString, expires: expiring)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
    
    /// Load image async from a url via a completion block using a given key to store.
    static func load(from url: URL,
                     expiring: CacheExpiry = ARConstants.Cache.sharedImageCacheExpiry,
                     key: String, completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image from url: \(url.absoluteString)")
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data from url: \(url.absoluteString)")
                return
            }
            
            UIImage.sharedCache?.setObject(image, forKey: key, expires: expiring)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
    
    static func load(fromFirebase firebaseUrl:URL, completion: @escaping ImageCacheCompletion) {
        if let image = UIImage.cachedImage(forKey: firebaseUrl.absoluteString) {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        Storage.storage().reference(forURL: firebaseUrl.absoluteString).downloadURL(completion: {(url, error) in
            guard let url = url else {
                return
            }
            UIImage.load(from: url, key: firebaseUrl.absoluteString, completion: { (image) in
                DispatchQueue.main.async {
                    completion(image)
                }
            })
        })
    }
    
    static func cachedImage(forKey key: String) -> UIImage? {
        return UIImage.sharedCache?.object(forKey: key)
    }
    
}
