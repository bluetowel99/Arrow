
import UIKit

public protocol ARForm {
    
    var requiredFormFields: [ARFormTextField] { get set }
    var allFormFields: [ARFormTextField] { get set }
    var actionButton: UIButton! { get set }
    var inputAccessoryActionButton: UIButton! { get set }
    
    func formSetup()
    func checkAllRequiredFieldsNonEmpty(defaultErrorMessage: String) -> Bool
    func checkAgainstOwnValidation(field: ARFormTextField) -> Bool
    func checkFormBeforeSubmission() -> Bool
    
}

public extension ARForm where Self: UIViewController {
    
    func checkAllRequiredFieldsNonEmpty(defaultErrorMessage: String) -> Bool {
        let allFieldsNonEmpty = requiredFormFields.reduce(true) {
            let nonEmpty = $1.text?.isEmpty == false
            
            // Highlight fields with error.
            $1.hideErrorMessage()
            if nonEmpty == false {
                let errorMessage = $1.validationErrorMessage ?? defaultErrorMessage
                $1.show(errorMessage: errorMessage)
            }
            
            return $0 && nonEmpty
        }
        return allFieldsNonEmpty
    }
    
    func checkAgainstOwnValidation(field: ARFormTextField) -> Bool {
        if field.invalid {
            field.show(errorMessage: field.validationErrorMessage)
        } else {
            field.hideErrorMessage()
        }
        return field.invalid == false
    }
    
    func checkFormBeforeSubmission() -> Bool {
        for field in requiredFormFields {
            if self.checkAgainstOwnValidation(field: field) == false {
                field.show(errorMessage: field.validationErrorMessage)
                break
            }
        }
        
        // Animate changes in layout.
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Proceed with API calls, only if all fields are valid.
        let allFieldsValid = requiredFormFields.reduce(true) {
            let valid = !$1.invalid
            let nonEmpty = $1.text?.isEmpty == false
            return $0 && valid && nonEmpty
        }
        return allFieldsValid
    }
    
}
