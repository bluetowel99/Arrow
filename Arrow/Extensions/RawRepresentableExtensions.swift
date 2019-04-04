
extension RawRepresentable {
    init?(rawValue: RawValue?) {
        guard let rawValue = rawValue else {
            return nil
        }
        
        self.init(rawValue: rawValue)
    }
}

// MARK: - allValues for UInt RawRepresentables

extension RawRepresentable where RawValue == UInt {
    
    static var allValues: [Self] {
        var idx = UInt.min
        return Array(AnyIterator { let i = idx; idx += 1; return Self(rawValue: i) })
    }
    
}
