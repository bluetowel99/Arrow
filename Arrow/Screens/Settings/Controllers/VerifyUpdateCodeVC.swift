
import UIKit
import SVProgressHUD

final class VerifyUpdateCodeVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.verifyCode()
    
    @IBOutlet weak var verificationCodeField: ARFormTextField!
    @IBOutlet weak var actionButton: UIButton!
    
    var user: ARPerson!
    var deviceUniqueId: String!
    var selectedProfilePicture: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitleStyle = .fullLogo
        setupView()
        setLocalizableStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let _ = verificationCodeField.textField.becomeFirstResponder()
    }
    
}

// MARK: - UI Helpers

extension VerifyUpdateCodeVC {
    
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

extension VerifyUpdateCodeVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        guard let phoneNumber = user.phone,
            let deviceUniqueId = deviceUniqueId,
            let verificationCode = verificationCodeField.text else {
                return
        }
        
        requestCodeVerification(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId, verificationCode: verificationCode)
    }
    
    fileprivate func performSaveProfileUpdates() {
            guard let user = user else {
                return
            }
        
            SVProgressHUD.show()
            updateProfile(person: user) { error in
                if let error = error {
                    print("EditProfileVC Error updating profile: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "An error occured updating your profile, please try again.")
                    self.navigationController?.popToRootViewController(animated: true)
                    return
                }
                
                self.platform.refreshUserProfile(networkSession: self.networkSession, completion: { error in
                    if let error = error {
                        print("Error fetching latest user profile:\n\(error)")
                        SVProgressHUD.showError(withStatus: "An error occured returning you profile, please try again.")
                        return
                    }
                    
                    self.performPhotoUpload()
                })
            }
        }
    
    fileprivate func performPhotoUpload() {
        if let selectedProfilePicture = selectedProfilePicture {
            uploadProfilePicture(image: selectedProfilePicture) { error in
                if let error = error {
                    print("Error uploading user profile picture:\n\(error)")
                    SVProgressHUD.showError(withStatus: "An error occured updating your profile picture, please try again.")
                    return
                }
                
                self.platform.refreshUserProfile(networkSession: self.networkSession, completion: { error in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        print("Error fetching latest user profile:\n\(error)")
                        SVProgressHUD.showError(withStatus: "An error occured returning you profile, please try again.")
                        return
                    }
                    
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
            return
        } else {
            self.platform.refreshUserProfile(networkSession: self.networkSession, completion: { error in
                SVProgressHUD.dismiss()
                if let error = error {
                    print("Error fetching latest user profile:\n\(error)")
                    SVProgressHUD.showError(withStatus: "An error occured returning you profile, please try again.")
                    return
                }
                
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
        
    }
}

// MARK: - Networking

extension VerifyUpdateCodeVC {
    
    func requestCodeVerification(phoneNumber: String, deviceUniqueId: String, verificationCode: String) {
        SVProgressHUD.show()
        let verifyCodeReq = VerifyCodeRequest(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId, verificationCode: verificationCode)
        let _ = networkSession?.send(verifyCodeReq) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                print("Code verification API call succeeded.")
                let signupFormVC = SignupFormVC.instantiate()
                signupFormVC.phoneNumber = phoneNumber
                self.performSaveProfileUpdates()
            case .failure(let error):
                print("VerifyCodeRequest error: \(error)")
            }
        }
    }
    
    func updateProfile(person: ARPerson, callback: ((NSError?) -> Void)?) {
        let request = UpdateMyProfileRequest(platform: platform, user: person, password: nil)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
    func uploadProfilePicture(image: UIImage, callback: ((NSError?) -> Void)?) {
        let uploadProfilePicReq = UploadProfilePictureRequest(platform: platform, profilePicture: image)
        let _ = networkSession?.send(uploadProfilePicReq) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
}
