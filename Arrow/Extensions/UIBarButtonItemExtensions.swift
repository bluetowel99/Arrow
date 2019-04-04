
import UIKit

extension UIBarButtonItem {
    
    func setTitleTextColor(_ color: UIColor, for state: UIControlState) {
        var textAttrs = UIBarButtonItem.appearance().titleTextAttributes(for: state)
        textAttrs?[NSAttributedStringKey.foregroundColor.rawValue] = color
        if let textAttrs = textAttrs {
            let convertedAttributes = Dictionary(uniqueKeysWithValues:
                textAttrs.lazy.map { (NSAttributedStringKey($0.key), $0.value) }
            )
            setTitleTextAttributes(convertedAttributes, for: state)
        }
    }
    
}
