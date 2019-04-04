
import UIKit

final class ResetPasswordNewPassVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.resetPasswordNewPass()
    
    @IBOutlet weak var passwordField: ARFormTextField!
    @IBOutlet weak var confirmPasswordField: ARFormTextField!
    @IBOutlet weak var setPasswordButton: ARButton!
    
    var actionButton: UIButton!
    var inputAccessoryActionButton: UIButton! = nil
    
    @IBOutlet var allFormFields = [ARFormTextField]() {
        didSet {
            let _ = allFormFields.map {
                $0.textFieldDelegate = self
            }
        }
    }
    @IBOutlet var requiredFormFields = [ARFormTextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitleStyle = .fullLogo
        setupView()
        setLocalizableStrings()
    }
    
}

// MARK: - UI Helpers

extension ResetPasswordNewPassVC {
    
    fileprivate func setupView() {
        // Setup action button.
        actionButton = setPasswordButton
        actionButton.layer.cornerRadius = 5.0
        actionButton.setTitleColor(R.color.arrowColors.silver(), for: .disabled)
        actionButton.setTitleColor(R.color.arrowColors.vanillaWhite(), for: .normal)
        actionButton.isEnabled = false
        // Setup form.
        formSetup()
    }
    
    fileprivate func setLocalizableStrings() { }
    
    func formSetup() {
        allFormFields = [passwordField, confirmPasswordField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        passwordField.setup(placeholder: "Password", isSecureTextEntry: true, keyboardType: .asciiCapable, validationMessage: "Password must be at least \(ARConstants.FormValidation.minPasswordLength) characters")
        passwordField.validationTester = {
            ($0 == nil) ? false : $0!.count >= ARConstants.FormValidation.minPasswordLength
        }
        
        confirmPasswordField.setup(placeholder: "Confirm password", isSecureTextEntry: true, keyboardType: .asciiCapable, validationMessage: "Passwords do not match")
        confirmPasswordField.validationTester = { $0 == self.passwordField.text }
        
        let _ = requiredFormFields.map {
            $0.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    fileprivate func updateActionButtonState() {
        let allNonEmpty = requiredFormFields.reduce(true) { $0 && ($1.text?.isEmpty == false) }
        actionButton.isEnabled = allNonEmpty
    }
    
}

// MARK: - Event Handlers

extension ResetPasswordNewPassVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        if checkAllRequiredFieldsNonEmpty(defaultErrorMessage: "Required") == false {
            return
        }
        
        if checkFormBeforeSubmission() == false {
            return
        }
        
        updatePassword(newPassword: passwordField.text!) { error in
            if let error = error {
                print("Error setting new password: \(error)")
                return
            }
            
            // Switch to logged-in mode.
            self.platform.requestRootViewControllerUpdate(switchingToLoggedInMode: true)
        }
    }
    
    @objc func textFieldDidChange(_ sender: AnyObject) {
        updateActionButtonState()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension ResetPasswordNewPassVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Networking

extension ResetPasswordNewPassVC {
    
    fileprivate func updatePassword(newPassword: String, callback: ((NSError?) -> Void)?) {
        let verificationReq = UpdateMyProfileRequest(platform: platform, user: nil, password: newPassword)
        let _ = networkSession?.send(verificationReq) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
}
