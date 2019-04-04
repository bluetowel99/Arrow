
import Foundation

import UIKit

enum ARMediaInputType: String {
    case image = "image"
    case video = "video"
    case sound = "sound"
    case location = "location"
    case poll = "poll"
}


class ARMediaInputData {

    var type: ARMediaInputType
    var image: UIImage?
    var caption: String?
    var movieUrl: String?
    var placeId: String?
    var address: String?
    var placeName: String?
    var identifier: String

    init(type: ARMediaInputType, image: UIImage?, movieUrl: String?) {
        self.identifier = UUID().uuidString
        self.type = type
        self.image = image
        self.movieUrl = movieUrl
    }


}
