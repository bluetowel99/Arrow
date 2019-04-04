
import APIKit
import UIKit

struct UploadProfilePictureRequest: ARRequest {
    
    let profilePicture: UIImage
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .patch
    }
    
    var path: String {
        return "/users/me/picture/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var bodyParameters: BodyParameters? {
        guard let imageData = UIImageJPEGRepresentation(profilePicture, 0.8) else {
            return nil
        }
        
        let imagePart = MultipartFormDataBodyParameters.Part(data: imageData, name: "upload", mimeType: "image/jpeg", fileName: "profile_picture.jpg")
        let uploadParam = MultipartFormDataBodyParameters(parts: [imagePart])
        return uploadParam
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, profilePicture: UIImage) {
        self.platform = platform
        self.profilePicture = profilePicture
    }    
}
