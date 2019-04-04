
import APIKit
import UIKit

struct UpdateBubblePictureRequest: ARRequest {
    
    let bubbleId: String
    let bubblePic: UIImage?
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/bubbles/\(bubbleId))/picture/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var bodyParameters: BodyParameters? {
        var parts: [MultipartFormDataBodyParameters.Part] = []
        
        // Add picture data, if available.
        if let imageData = getImageData() {
            let imagePart = MultipartFormDataBodyParameters.Part(data: imageData, name: "upload", mimeType: "image/jpeg", fileName: "bubble_picture.jpg")
            parts.append(imagePart)
        }
        
        return MultipartFormDataBodyParameters(parts: parts)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubbleId: String, bubblePicture: UIImage?) {
        self.platform = platform
        self.bubbleId = bubbleId
        self.bubblePic = bubblePicture
    }
    
    // MARK: Helpers
    
    fileprivate func getImageData() -> Data? {
        guard let picture = bubblePic else {
            return nil
        }
        
        return UIImageJPEGRepresentation(picture, 0.8)
    }
    
}
