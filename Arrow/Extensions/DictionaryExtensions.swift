
import Foundation

// MARK: - Removing Nils Extension

protocol OptionalEquivalent {
    associatedtype Wrapped
    func toOptional() -> Wrapped?
}

extension Optional: OptionalEquivalent {
    
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    func toOptional() -> Wrapped? {
        return self
    }
    
}

extension Dictionary where Value: OptionalEquivalent {
    
    /// Returns Dictionary with all nils removed.
    func nilsRemoved() -> Dictionary<Key, Value.Wrapped> {
        var result = Dictionary<Key, Value.Wrapped>()
        for (key, value) in self {
            guard let value = value.toOptional() else { continue }
            result[key] = value
        }
        return result
    }
    
}

