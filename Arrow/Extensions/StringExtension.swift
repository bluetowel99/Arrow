
import Foundation

extension String {
    func cleanPhoneFormat() -> String? {

        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(self, defaultRegion: "US")
            let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            return formattedString
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
