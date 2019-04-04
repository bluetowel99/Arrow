
import Foundation

/// Protocol for dictionary representable (encodable/decodable) values.
protocol Dictionariable {
    
    associatedtype Key: Hashable
    
    func dictionaryRepresentation() -> Dictionary<Key, Any>
    
    init?(with dictionary: Dictionary<Key, Any>?)
    
    init?(with object: Any?)
    
}

// MARK: - Default Implementation

extension Dictionariable {
    
    init?(with object: Any?) {
        guard let dictionary = object as? Dictionary<Key, Any> else {
            return nil
        }
        self.init(with: dictionary)
    }
    
}

// MARK: - Array of Dictionariable Implementation

extension Array where Element: Dictionariable {
    
    init?(with dictionary: [[Element.Key: Any]]) {
        self.init()
        let _ = dictionary.map { dict in
            if let address = Element(with: dict as Dictionary<Element.Key, Any>?) {
                self.append(address)
            }
        }
        
    }
    
    func dictionaryRepresentation() -> [Dictionary<Element.Key, Any>] {
        let arrayDict = self.reduce([Dictionary<Element.Key, Any>]()) {
            let dictRep = $1.dictionaryRepresentation()
            var arr = $0
            arr.append(dictRep)
            return arr
        }
        
        return arrayDict
    }
    
}
