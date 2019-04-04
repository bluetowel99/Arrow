
import APIKit
import UIKit

struct CreateBubbleRequest: ARRequest {
    
    let bubble: ARBubble
    
    typealias Response = ARBubble
    
    var platform: ARPlatform
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/bubbles/"
    }
    
    var headerFields: [String: String] {
        return sessionHeaderFields
    }
    
    var bodyParameters: BodyParameters? {
        var parts: [MultipartFormDataBodyParameters.Part] = []
        
        // Add bubble title.
        do {
            let titlePart = try MultipartFormDataBodyParameters.Part(value: bubble.title, name: "title")
            parts = [titlePart]
        } catch let error {
            print("Error parsing title body parameter:\n\(error.localizedDescription)")
        }
        
        // Add bubble members.
        var membersPhoneNums = [String!]()
        do {
            for m in bubble.members!
            {
                print(m.filteredPhone()!)
                membersPhoneNums.append(m.filteredPhone()!)
                let membersPart = try MultipartFormDataBodyParameters.Part(value: m.filteredPhone()!, name: "members")
                parts.append(membersPart)
            }
        } catch let error {
            print("Error parsing members array body parameter:\n\(error.localizedDescription)")
        }
        
        // Add picture data, if available.
        if let imageData = getImageData() {
            let imagePart = MultipartFormDataBodyParameters.Part(data: imageData, name: "picture", mimeType: "image/jpeg", fileName: "bubble_picture.jpg")
            parts.append(imagePart)
        }
        
        print("end of bodyParamters in CreateBubbleRequest")
        print(membersPhoneNums)
        
        return MultipartFormDataBodyParameters(parts: parts)
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> ARBubble {
        guard let bubbleDict = object as? NSDictionary,
            let bubble = ARBubble(with: bubbleDict) else {
                throw ResponseError.unexpectedObject(object)
        }
        return bubble
    }
    
    init(platform: ARPlatform = ARPlatform.shared, bubble: ARBubble) {
        self.platform = platform
        self.bubble = bubble
    }
    
    // MARK: Helpers
    
    fileprivate func getImageData() -> Data? {
        guard let picture = bubble.picture else {
            return nil
        }
        
        return UIImageJPEGRepresentation(picture, 0.8)
    }
    
}
