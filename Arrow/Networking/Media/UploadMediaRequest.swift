
import APIKit
import UIKit

struct UploadMediaRequest: ARRequest {
    
    let photo: UIImage?
    let movieFileURL: URL?
    let caption: String?
    // TODO(kia): Add location information.
    
    typealias Response = ARMedia
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/media/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var bodyParameters: BodyParameters? {
        var bodyParams: MultipartFormDataBodyParameters.Part? = nil
        
        if let photo = photo {
            bodyParams = getPhotoBodyParams(photo: photo)
        } else if let movieFileURL = movieFileURL {
            bodyParams = getMovieBodyParams(movieFileURL: movieFileURL)
        } else {
            assertionFailure("Neither an image nor a video file available to be uploaded.")
        }
        
        guard let mediaPart = bodyParams else {
            return nil
        }
        
        var parts: [MultipartFormDataBodyParameters.Part] = [mediaPart]
        
        // Add caption info to upload params.
        do {
            let caption = self.caption ?? ""
            let captionPart = try MultipartFormDataBodyParameters.Part(value: caption, name: "caption")
            parts.append(captionPart)
        } catch let error {
            print("Error parsing caption body parameter:\n\(error.localizedDescription)")
        }
        
        // Add location info to upload params.
        do {
            // TODO(kia): Add location information to upload params.
            let location = ""
            let locationPart = try MultipartFormDataBodyParameters.Part(value: location, name: "location")
            parts.append(locationPart)
        } catch let error {
            print("Error parsing location body parameter:\n\(error.localizedDescription)")
        }
        
        return MultipartFormDataBodyParameters(parts: parts)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARMedia {
        guard let mediaDict = object as? NSDictionary,
            let media = ARMedia(with: mediaDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        
        return media
    }
    
    init(platform: ARPlatform = ARPlatform.shared, photo: UIImage?, movieFileURL: URL?, caption: String?) {
        self.platform = platform
        self.photo = photo
        self.movieFileURL = movieFileURL
        self.caption = caption
    }
    
    // MARK: - Media Upload Helpers
    
    fileprivate func getPhotoBodyParams(photo: UIImage) -> MultipartFormDataBodyParameters.Part? {
        guard let imageData = UIImageJPEGRepresentation(photo, 0.8) else {
            return nil
        }
        
        let filename = "\(Date().timeIntervalSince1970)_photo.jpg"
        let mediaPart = MultipartFormDataBodyParameters.Part(data: imageData, name: "file", mimeType: "image/jpeg", fileName: filename)
        
        return mediaPart
    }
    
    fileprivate func getMovieBodyParams(movieFileURL: URL) -> MultipartFormDataBodyParameters.Part? {
        do {
            let fileData = try Data.init(contentsOf: movieFileURL, options: .dataReadingMapped)
            let filename = "\(Date().timeIntervalSince1970)_movie.mp4"
            let mediaPart = MultipartFormDataBodyParameters.Part(data: fileData, name: "file", mimeType: "video/mp4", fileName: filename)
            
            return mediaPart
        } catch {
            return nil
        }
    }
    
}
