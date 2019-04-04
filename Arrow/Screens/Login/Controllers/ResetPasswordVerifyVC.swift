
import UIKit

final class ResetPasswordVerifyVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.resetPasswordVerify()
    
    @IBOutlet weak var verificationCodeField: ARFormTextField!
    @IBOutlet weak var resetButton: ARButton!
    @IBOutlet weak var resendButton: UIButton!
    
    var actionButton: UIButton!
    var inputAccessoryActionButton: UIButton! = nil
    
    /// User's email address, passed to the screen from previous steps.
    var emailAddress: String?
    
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

extension ResetPasswordVerifyVC {
    
    fileprivate func setupView() {
        // Setup action button.
        actionButton = resetButton
        actionButton.layer.cornerRadius = 5.0
        actionButton.setTitleColor(R.color.arrowColors.silver(), for: .disabled)
        actionButton.setTitleColor(R.color.arrowColors.vanillaWhite(), for: .normal)
        actionButton.isEnabled = false
        // Setup form.
        formSetup()
    }
    
    fileprivate func setLocalizableStrings() { }
    
    func formSetup() {
        allFormFields = [verificationCodeField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        verificationCodeField.setup(placeholder: "Enter code", keyboardType: .emailAddress)
        
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

extension ResetPasswordVerifyVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        guard let emailAddress = emailAddress else {
            assertionFailure("Email address should not be nil.")
            return
        }
        
        if checkAllRequiredFieldsNonEmpty(defaultErrorMessage: "Required") == false {
            return
        }
        
        if checkFormBeforeSubmission() == false {
            return
        }
        
        verifyResetPassword(email: emailAddress, code: verificationCodeField.text!) { error in
            if let error = error {
                print("Error verifying reset-password code:\n\(error)")
                return
            }
            
            // Navigate to set new password screen.
            let newPassVC = ResetPasswordNewPassVC.instantiate()
            self.navigationController?.pushViewController(newPassVC, animated: true)
        }
    }
    
    @IBAction func resendCodePressed(_ sender: AnyObject) {
        guard let emailAddress = emailAddress else {
            assertionFailure("Email address should not be nil.")
            return
        }
        
        resetPassword(email: emailAddress) { error in
            if let error = error {
                print("Error re-sending reset password request:\n\(error)")
                return
            }
            
            // Show confirmation for successful re-send request.
            let alertController = UIAlertController(title: "Resend Success", message: "We emailed you a new verification code.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(_ sender: AnyObject) {
        updateActionButtonState()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension ResetPasswordVerifyVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Networking

extension ResetPasswordVerifyVC {
    
    fileprivate func verifyResetPassword(email: String, code: String, callback: ((NSError?) -> Void)?) {
        let verificationReq = ResetPasswordVerifyRequest(platform: platform, email: email, verificationCode: code)
        let _ = networkSession?.send(verificationReq) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
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
