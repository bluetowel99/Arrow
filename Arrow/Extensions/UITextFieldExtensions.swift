
import UIKit

// MARK: - Placeholder Extensions

extension UITextField {
    
    func setPlaceholder(color: UIColor) {
        if let placeholderText = self.placeholder {
            self.setPlaceholder(text: placeholderText, color: color)
        }
    }
    
    func setPlaceholder(text: String, color: UIColor) {
        let attrs = [NSAttributedStringKey.foregroundColor: color]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attrs)
    }
    
}

// MARK: - InputView Related Extensions

extension UITextField {
    
    /// Add Done button to inputAccessoryView.
    func addDoneButtonToInputAccessoryView(buttonTitle title: String?, rightAligned: Bool) {
        var toolbarButtons = [UIBarButtonItem]()
        // Add flex button first, if Done button's right aligned.
        if rightAligned == true {
            let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbarButtons.append(flexButton)
        }
        // Add Done button.
        let doneButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(endEditingImmediately(_:)))
        toolbarButtons.append(doneButtonItem)
        
        addToolbarButtonsToInputAccessoryView(toolbarButtons)
    }
    
    /// Add toolbar buttons to inputAccessoryView.
    func addToolbarButtonsToInputAccessoryView(_ toolbarButtons: [UIBarButtonItem]) {
        let inputAccessoryViewToolbar = UIToolbar()
        inputAccessoryViewToolbar.setItems(toolbarButtons, animated: false)
        inputAccessoryViewToolbar.sizeToFit()
        
        inputAccessoryView = inputAccessoryViewToolbar
    }
    
    // Resign first responder.
    @objc func endEditingImmediately(_ sender: AnyObject) {
        resignFirstResponder()
    }
    
}
