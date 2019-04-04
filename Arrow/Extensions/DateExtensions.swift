
import Foundation

extension Date {
    func asEnglish() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        var dateString = dateFormatter.string(from: self)
        dateString = dateString.replacingOccurrences(of: "at", with: "@")
        return dateString
    }
}


