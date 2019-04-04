
import APIKit
import UIKit

struct RatePlaceRequest: ARRequest {
    
    let googlePlaceId: String
    let rating: ARPlaceRating
    let comment: String
    var pictures = [UIImage]()
    
    typealias Response = Bool
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/places/\(googlePlaceId)/comment/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var bodyParameters: BodyParameters? {
        var imageParts = [MultipartFormDataBodyParameters.Part]()
        for i in 0..<pictures.count {
            guard let imageData = UIImageJPEGRepresentation(pictures[i], 0.5) else {
                return nil
            }
            
            let imagePart = MultipartFormDataBodyParameters.Part(data: imageData, name: "image_\(i + 1)", mimeType: "image/jpeg", fileName: "comment_picture_\(i + 1).jpg")
            imageParts.append(imagePart)
        }

        imageParts.append(MultipartFormDataBodyParameters.Part(data: comment.data(using: String.Encoding.utf8)!, name: "comment"))
        imageParts.append(MultipartFormDataBodyParameters.Part(data: String(format: "%d", Int(rating.experience ?? 0)).data(using: String.Encoding.utf8)!, name: "experience"))
        imageParts.append(MultipartFormDataBodyParameters.Part(data: String(format: "%d", Int(rating.food ?? 0)).data(using: String.Encoding.utf8)!, name: "food"))
        imageParts.append(MultipartFormDataBodyParameters.Part(data: String(format: "%d", Int(rating.atmosphere ?? 0)).data(using: String.Encoding.utf8)!, name: "atmosphere"))
        imageParts.append(MultipartFormDataBodyParameters.Part(data: String(format: "%d", Int(rating.service ?? 0)).data(using: String.Encoding.utf8)!, name: "service"))
        
        let uploadParam = MultipartFormDataBodyParameters(parts: imageParts)
        return uploadParam
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Bool {
        return true
    }
    
    init(platform: ARPlatform = ARPlatform.shared, googlePlaceId: String, rating: ARPlaceRating, comment: String, pictures: [UIImage]) {
        self.platform = platform
        self.googlePlaceId = googlePlaceId
        self.rating = rating
        self.comment = comment
        self.pictures = pictures
    }
}
