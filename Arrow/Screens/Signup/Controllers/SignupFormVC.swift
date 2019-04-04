
import UIKit
import FirebaseMessaging
import SVProgressHUD

final class SignupFormVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.signupForm()
    var phoneNumber:String = ""
    @IBOutlet weak var firstNameField: ARFormTextField!
    @IBOutlet weak var lastNameField: ARFormTextField!
    @IBOutlet weak var emailField: ARFormTextField!
    @IBOutlet weak var passwordField: ARFormTextField!
    @IBOutlet weak var confirmPasswordField: ARFormTextField!
    @IBOutlet weak var actionButton: UIButton!

    // TODO: Clean up later when not necessary for protocol
    @IBOutlet weak var inputAccessoryActionButton: UIButton!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameField.textField.becomeFirstResponder()
    }
    
}

// MARK: - UI Helpers

extension SignupFormVC {
    
    fileprivate func setupView() {
        formSetup()
        addHideKeyboardTapGestRecognizer()
    }
    
    fileprivate func setLocalizableStrings() {
        actionButton.setTitle(R.string.signup.formNextButtonTitle(), for: .normal)
    }
    
    fileprivate func navigateToCongratsScreen() {
        let congratsVC = SignupCongratsVC.instantiate()
        self.navigationController?.pushViewController(congratsVC, animated: true)
    }
    
}

// MARK: - ARForm Implementation

extension SignupFormVC {
    
    func formSetup() {
        allFormFields = [firstNameField, lastNameField, emailField, passwordField, confirmPasswordField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        firstNameField.setup(placeholder: R.string.signup.formFirstNameFieldPlaceholder(), keyboardType: .asciiCapable, validationMessage: "First name required", autoCapitalization: true)
        
        lastNameField.setup(placeholder: R.string.signup.formLastNameFieldPlaceholder(), keyboardType: .asciiCapable, validationMessage: "Last name required", autoCapitalization: true)
        
        emailField.setup(placeholder: R.string.signup.formEmailFieldPlaceholder(), keyboardType: .emailAddress, validationMessage: "Please enter a valid email address")
        emailField.validationTester = ARFormValidation.Testers.email
        
        passwordField.setup(placeholder: R.string.signup.formPasswordFieldPlaceholder(), isSecureTextEntry: true, keyboardType: .asciiCapable, validationMessage: "Password must be at least \(ARConstants.FormValidation.minPasswordLength) characters")
        passwordField.validationTester = {
            ($0 == nil) ? false : $0!.count >= ARConstants.FormValidation.minPasswordLength
        }
        
        confirmPasswordField.setup(placeholder: R.string.signup.formConfirmPasswordFieldPlaceholder(), isSecureTextEntry: true, keyboardType: .asciiCapable, validationMessage: "Passwords do not match")
        confirmPasswordField.validationTester = { $0 == self.passwordField.text }
    }
    
}

// MARK: - Logic Helpers

extension SignupFormVC {
    
    fileprivate func performUserProfileSubmission() {
        let user = ARPerson(
            firstName: firstNameField.text,
            lastName: lastNameField.text,
            email: emailField.text,
            pictureUrl: nil)

        SVProgressHUD.show()
        requestProfileUpdate(user: user, password: passwordField.text) { error in
            if let error = error {
                print("SignupFormVC Error updating profile: \(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "An error occured creating your account, please try again.")
                return
            }

            
            // "done" signing up - let's ensure that the token is attached to this user
            let t = Messaging.messaging().fcmToken;
            if(t != nil)
            {
                let request = UpdateMyDeviceRequest(platform: ARPlatform.shared, token: Messaging.messaging().fcmToken!)
                let networkSession = ARNetworkSession.shared
                let _ = networkSession.send(request) { result in
                    
                    switch result {
                    case .success(_):
                        print("SUCCESS: token data sent to server - ready for push notifications")
                    case .failure(let error):
                        print("ERROR: token data send error: \(error)")
                    }
                }
            }
            
            self.performUserProfileRefresh()
        }
    }
    
    fileprivate func performUserProfileRefresh() {
        platform.refreshUserProfile(networkSession: networkSession, completion: { error in
            if let error = error {
                print("Error fetching latest user profile: \(error.localizedDescription)")
                SVProgressHUD.showError(withStatus: "An error occured returning you profile, please try again.")
                return
            }

            SVProgressHUD.dismiss()
            self.navigateToCongratsScreen()
        })
    }
    
}

// MARK: - Event Handlers

extension SignupFormVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        if checkAllRequiredFieldsNonEmpty(defaultErrorMessage: "Required field") == false {
            return
        }
        
        if checkFormBeforeSubmission() == false {
            return
        }
        
        performUserProfileSubmission()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension SignupFormVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Networking

extension SignupFormVC {
    
    fileprivate func requestProfileUpdate(user: ARPerson, password: String?, callback: ((NSError?) -> Void)?) {
        let request = SignUpProfileRequest(platform:platform, email:emailField.text, firstName:firstNameField.text, lastName:lastNameField.text, mobile:phoneNumber, password:password)
        let _ = networkSession?.send(request) { result in
            
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
}
