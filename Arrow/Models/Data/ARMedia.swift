
import Foundation


/// Arrow's Media data model.
struct ARMedia {
    
    var identifier: Int?
    var createdBy: ARPerson?
    var caption: String?
    var fileUrl: URL?
    var shareInfo: ARShareInfo?
    var votes : [String: Bool]?
    
    init(identifier: Int? = nil, createdBy: ARPerson? = nil, caption: String? = nil, fileUrl: URL? = nil, shareInfo: ARShareInfo? = nil) {
        self.identifier = identifier
        self.createdBy = createdBy
        self.caption = caption
        self.fileUrl = fileUrl
        self.shareInfo = shareInfo
    }
    
}

// MARK: - Dictionariable Implementation

extension ARMedia: Dictionariable {
    
    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var createdBy = "created_by"
        static var caption = "caption"
        static var fileUrl = "file"
        static var shareInfo = "shares"
        static var votes = "votes"
    }
    
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }
        
        identifier = dictionary[Keys.identifier] as? Int
        
        if let personDict = dictionary[Keys.createdBy] as? NSDictionary,
            let creator = ARPerson(with: personDict) {
            self.createdBy = creator
        }
        
        caption = dictionary[Keys.caption] as? String
        
        if let urlString = dictionary[Keys.fileUrl] as? String {
            fileUrl = URL(string: urlString)
        }
        
        if let shareDict = dictionary[Keys.shareInfo] as? NSDictionary,
            let shareInfo = ARShareInfo(with: shareDict) {
            self.shareInfo = shareInfo
        }
        votes = dictionary[Keys.votes] as? [String:Bool]
    }
    
    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.createdBy: createdBy?.dictionaryRepresentation(),
            Keys.caption: caption,
            Keys.fileUrl: fileUrl?.absoluteString,
            Keys.shareInfo: shareInfo?.dictionaryRepresentation(),
            ]
        return dict.nilsRemoved()
    }
    
}
