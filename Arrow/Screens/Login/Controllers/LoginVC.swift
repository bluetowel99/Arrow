
import UIKit
import FirebaseAuth
import SVProgressHUD

final class LoginVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.login()
    
    @IBOutlet weak var emailField: ARFormTextField!
    @IBOutlet weak var passwordField: ARFormTextField!
    @IBOutlet weak var loginButton: ARButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
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
        setupView()
        setLocalizableStrings()
    }
    
}

// MARK: - UI Helpers

extension LoginVC {
    
    fileprivate func setupView() {
        actionButton = loginButton
        // Setup login button.
        loginButton.layer.cornerRadius = 5.0
        loginButton.setTitleColor(R.color.arrowColors.silver(), for: .disabled)
        loginButton.setTitleColor(R.color.arrowColors.vanillaWhite(), for: .normal)
        loginButton.isEnabled = false
        // Setup form.
        formSetup()
    }
    
    fileprivate func setLocalizableStrings() { }
    
    func formSetup() {
        allFormFields = [emailField, passwordField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        emailField.setup(placeholder: R.string.login.formEmailFieldPlaceholder(), keyboardType: .emailAddress, validationMessage: "Please enter a valid email address")
        emailField.validationTester = ARFormValidation.Testers.email
        
        passwordField.setup(placeholder: R.string.login.formPasswordFieldPlaceholder(), isSecureTextEntry: true, keyboardType: .asciiCapable, validationMessage: "Password must be at least \(ARConstants.FormValidation.minPasswordLength) characters")
        passwordField.validationTester = {
            ($0 == nil) ? false : $0!.count >= ARConstants.FormValidation.minPasswordLength
        }
        
        let _ = requiredFormFields.map {
            $0.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    fileprivate func updateLoginButtonState() {
        let allNonEmpty = requiredFormFields.reduce(true) { $0 && ($1.text?.isEmpty == false) }
        loginButton.isEnabled = allNonEmpty
    }
    
}

// MARK: - Logic Helpers

extension LoginVC {
    
    fileprivate func performUserLogin() {
        SVProgressHUD.show()
        loginUser(email: emailField.text!, password: passwordField.text!) { error in
            if let error = error {
                print("Error logging in the user:\n\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "An error occured while logging in, please try again.")
                return
            }
            
            self.performFirebaseLogin()
        }
    }
    
    fileprivate func performFirebaseLogin() {
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if let error = error {
                print("Error logging into Firebase:\n\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "An error occured while logging in, please try again.")
                return
            }
            
            self.loadUserProfile()
        })
    }
    
    fileprivate func loadUserProfile() {
        platform.refreshUserProfile(networkSession: networkSession) { error in
            if let error = error {
                print("Error fetching user profile:\n\(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "An error occured retrieving your profile, please try again.")
                return
            }
            SVProgressHUD.dismiss()
            self.switchToLoggedInMode()
        }
    }
    
    fileprivate func switchToLoggedInMode() {
        self.platform.requestRootViewControllerUpdate(switchingToLoggedInMode: true)
    }
    
}

// MARK: - Event Handlers

extension LoginVC {
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        if checkAllRequiredFieldsNonEmpty(defaultErrorMessage: "Required") == false {
            return
        }
        
        if checkFormBeforeSubmission() == false {
            return
        }
        
        performUserLogin()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: AnyObject) {
        let resetPassVC = ResetPasswordEmailVC.instantiate()
        navigationController?.pushViewController(resetPassVC, animated: true)
    }
    
    @IBAction func signupButtonPressed(_ sender: AnyObject) {
        let signupVC = PhoneNumberVC.instantiate()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc func textFieldDidChange(_ sender: AnyObject) {
        updateLoginButtonState()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Networking

extension LoginVC {
    
    fileprivate func loginUser(email: String, password: String, callback: ((NSError?) -> Void)?) {
        let loginReq = LoginRequest(platform: platform, userName: email, password: password)
        let _ = networkSession?.send(loginReq) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
}
