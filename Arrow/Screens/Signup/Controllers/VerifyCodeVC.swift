
import UIKit
import SVProgressHUD

final class VerifyCodeVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.verifyCode()
    
    @IBOutlet weak var verificationCodeField: ARFormTextField!
    @IBOutlet weak var actionButton: UIButton!
    
    var phoneNumber: String!
    var deviceUniqueId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitleStyle = .fullLogo
        setupView()
        setLocalizableStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if phoneNumber == nil || deviceUniqueId == nil {
            assertionFailure("phoneNumber and deviceUniqueId should must be set.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = verificationCodeField.textField.becomeFirstResponder()
    }
    
}

// MARK: - UI Helpers

extension VerifyCodeVC {
    
    fileprivate func setupView() {
        setupNumberPad()
        addHideKeyboardTapGestRecognizer()
    }

    fileprivate func setupNumberPad() {
        verificationCodeField.textField.keyboardType = .numberPad

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.dismissKeyboard))

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        verificationCodeField.textField.inputAccessoryView = doneToolbar
    }
    
    fileprivate func setLocalizableStrings() {
        verificationCodeField.placeholder = R.string.signup.verifyCodeVerificationCodeFieldPlaceholder()
        actionButton.setTitle(R.string.signup.verifyCodeNextButtonTitle(), for: .normal)
    }
    
}

// MARK: - Event Handlers

extension VerifyCodeVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        guard let phoneNumber = phoneNumber,
            let deviceUniqueId = deviceUniqueId,
            let verificationCode = verificationCodeField.text else {
                return
        }
        
        requestCodeVerification(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId, verificationCode: verificationCode)
    }
    
}

// MARK: - Networking

extension VerifyCodeVC {
    
    fileprivate func requestCodeVerification(phoneNumber: String, deviceUniqueId: String, verificationCode: String) {
        SVProgressHUD.show()
        let verifyCodeReq = VerifyCodeRequest(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId, verificationCode: verificationCode)
        let _ = networkSession?.send(verifyCodeReq) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                print("Code verification API call succeeded.")
                let signupFormVC = SignupFormVC.instantiate()
                signupFormVC.phoneNumber = phoneNumber
                self.navigationController?.pushViewController(signupFormVC, animated: true)
            case .failure(let error):
                print("VerifyCodeRequest error: \(error)")
            }
        }
    }
    
}
