
import UIKit
import SVProgressHUD

final class PhoneNumberVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.phoneNumber()
    
    @IBOutlet weak var phoneNumberField: ARFormTextField!
    @IBOutlet weak var actionButton: UIButton!

    lazy var deviceUniqueId: String = {
        let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return "\(vendorId)"
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitleStyle = .fullLogo
        setupView()
        setLocalizableStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = phoneNumberField.textField.becomeFirstResponder()
    }
    
}

// MARK: - UI Helpers

extension PhoneNumberVC {
    
    fileprivate func setupView() {
        setupNumberPad()
        addHideKeyboardTapGestRecognizer()
    }

    fileprivate func setupNumberPad() {
        phoneNumberField.textField.keyboardType = .numberPad

        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.dismissKeyboard))

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        phoneNumberField.textField.inputAccessoryView = doneToolbar
    }
    
    fileprivate func setLocalizableStrings() {
        phoneNumberField.placeholder = R.string.signup.phoneNumberPhoneFieldPlaceholder()
        actionButton.setTitle(R.string.signup.phoneNumberNextButtonTitle(), for: .normal)
    }
    
}

// MARK: - Event Handlers

extension PhoneNumberVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        guard var phoneNum = phoneNumberField.text else {
            return
        }
        
        phoneNum = "+1\(phoneNum)"
        requestPhoneNumberRegisteration(phoneNumber: phoneNum, deviceUniqueId: deviceUniqueId)
    }
    
}

// MARK: - Networking

extension PhoneNumberVC {
    
    fileprivate func requestPhoneNumberRegisteration(phoneNumber: String, deviceUniqueId: String) {
        SVProgressHUD.show()
        let registerPhoneReq = RegisterPhoneRequest.init(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId)
        let _ = networkSession?.send(registerPhoneReq) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                print("Successful phone number registration API call.")
                let verifyCodeVC = VerifyCodeVC.instantiate()
                verifyCodeVC.phoneNumber = phoneNumber
                verifyCodeVC.deviceUniqueId = deviceUniqueId
                self.navigationController?.pushViewController(verifyCodeVC, animated: true)
            case .failure(let error):
                print("RegisterPhoneRequest error: \(error)")
            }
        }
    }
    
}
