
import Foundation

public struct ARFormValidation {
    
    public struct Testers {
        
        public static let email: ((String?) -> Bool) = {
            let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            return ARFormValidation.Testers.runRegEx(string: $0, regEx: emailRegEx)
        }
        
        private static func runRegEx(string: String?, regEx: String) -> Bool {
            guard string != nil else {
                return false
            }
            return NSPredicate(format:"SELF MATCHES %@", regEx).evaluate(with: string)
        }
        
    }
    
}
