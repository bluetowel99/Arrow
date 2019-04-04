
import Foundation

extension TimeInterval {
    var stringValue: String {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
