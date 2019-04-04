
import UIKit

final class ResetPasswordEmailVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.resetPasswordEmail()
    
    @IBOutlet weak var emailField: ARFormTextField!
    @IBOutlet weak var sendButton: ARButton!
    
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

extension ResetPasswordEmailVC {
    
    fileprivate func setupView() {
        // Setup action button.
        actionButton = sendButton
        actionButton.layer.cornerRadius = 5.0
        actionButton.setTitleColor(R.color.arrowColors.silver(), for: .disabled)
        actionButton.setTitleColor(R.color.arrowColors.vanillaWhite(), for: .normal)
        actionButton.isEnabled = false
        // Setup form.
        formSetup()
    }
    
    fileprivate func setLocalizableStrings() { }
    
    func formSetup() {
        allFormFields = [emailField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        emailField.setup(placeholder: "Enter your email", keyboardType: .emailAddress, validationMessage: "Please enter a valid email address")
        emailField.validationTester = ARFormValidation.Testers.email
        
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

extension ResetPasswordEmailVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        if checkAllRequiredFieldsNonEmpty(defaultErrorMessage: "Required") == false {
            return
        }
        
        if checkFormBeforeSubmission() == false {
            return
        }
        
        resetPassword(email: emailField.text!) { error in
            if let error = error {
                print("Error sending reset password request:\n\(error)")
                return
            }
            
            // Navigate to verification code screen.
            let verificationVC = ResetPasswordVerifyVC.instantiate()
            verificationVC.emailAddress = self.emailField.text
            self.navigationController?.pushViewController(verificationVC, animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ sender: AnyObject) {
        updateActionButtonState()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension ResetPasswordEmailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Networking

extension ResetPasswordEmailVC {
    
    fileprivate func resetPassword(email: String, callback: ((NSError?) -> Void)?) {
        let resetPassReq = ResetPasswordRequest(platform: platform, email: email)
        let _ = networkSession?.send(resetPassReq) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
}
