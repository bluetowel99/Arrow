
import UIKit
import SVProgressHUD

final class EditProfileVC: ARKeyboardViewController, StoryboardViewController, ARForm {
    
    static var kStoryboard: UIStoryboard = R.storyboard.editProfile()
    static var kStoryboardIdentifier: String? = "EditProfileVC"
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var changePicButton: UIButton!
    @IBOutlet weak var firstNameField: ARFormTextField!
    @IBOutlet weak var lastNameField: ARFormTextField!
    @IBOutlet weak var phoneField: ARFormTextField!
    @IBOutlet weak var emailField: ARFormTextField!
    
    var actionButton: UIButton! = nil
    var inputAccessoryActionButton: UIButton! = nil
    var allFormFields = [ARFormTextField]()
    var requiredFormFields = [ARFormTextField]()
    
    let choosePictureMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let imagePickerController = UIImagePickerController()
    var selectedProfilePicture: UIImage?
    
    lazy var deviceUniqueId: String = {
        let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return "\(vendorId)"
    }()
    
    var oldPhoneNumber = ""
    var user: ARPerson!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        formSetup()
        setupChoosePictureMenu()
        setupImagePicker()
        reloadProfileInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicImageView.layer.cornerRadius = profilePicImageView.bounds.width / 2.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVerifyPhoneNumberVC", let verifyUpdateVC = segue.destination as? VerifyUpdateCodeVC {
            verifyUpdateVC.user = self.user
            verifyUpdateVC.deviceUniqueId = deviceUniqueId
            verifyUpdateVC.selectedProfilePicture = self.selectedProfilePicture
        }
    }
}

extension EditProfileVC {
    
    fileprivate func setupView() {
        navigationBarTitle = "My Info"
        isNavigationBarBackTextHidden = true
        
        // Navigation bar buttons.
        let saveBarButton = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveButtonPressed(_:)))
        saveBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .disabled)
        saveBarButton.setTitleTextColor(R.color.arrowColors.waterBlue(), for: .normal)
        saveBarButton.isEnabled = true
        navigationItem.rightBarButtonItem = saveBarButton
    }
    
    func formSetup() {
        allFormFields = [firstNameField, lastNameField, phoneField, emailField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        firstNameField.setup(placeholder: R.string.signup.formFirstNameFieldPlaceholder(), keyboardType: .asciiCapable, validationMessage: "First name required", autoCapitalization: true)
        
        lastNameField.setup(placeholder: R.string.signup.formLastNameFieldPlaceholder(), keyboardType: .asciiCapable, validationMessage: "Last name required", autoCapitalization: true)
        
        phoneField.setup(placeholder: R.string.signup.phoneNumberPhoneFieldPlaceholder(), keyboardType: .numberPad, validationMessage: "Please enter a valid phone number")
        
        emailField.setup(placeholder: R.string.signup.formEmailFieldPlaceholder(), keyboardType: .emailAddress, validationMessage: "Please enter a valid email address")
        emailField.validationTester = ARFormValidation.Testers.email
        
        let _ = allFormFields.map {
            $0.textFont = R.font.alegreyaSansBold(size: 20.0)!
            $0.textFieldDelegate = self
        }
    }
    
    fileprivate func setupChoosePictureMenu() {
        let photoLibraryItem = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.showImagePicker(type: .photoLibrary)
        }
        choosePictureMenu.addAction(photoLibraryItem)
        let cameraItem = UIAlertAction(title: "Take Photo", style: .default) { action in
            self.showImagePicker(type: .camera)
        }
        choosePictureMenu.addAction(cameraItem)
        let cancelItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        choosePictureMenu.addAction(cancelItem)
    }
    
    fileprivate func setupImagePicker() {
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
    }
    
    fileprivate func reloadProfileInfo() {
        guard let user = platform.userSession?.user else {
            return
        }
        
        if let url = user.pictureUrl {
            profilePicImageView.setImage(from: url)
        }
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
        phoneField.text = user.phone
        emailField.text = user.email
        
        oldPhoneNumber = user.phone!
    }
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func navigateToPrevScreen() {
        if navigationController?.topViewController == self {
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func performSaveProfileUpdates() {
        guard let sessionUser = platform.userSession?.user else {
            return
        }
        
        self.user = sessionUser
        self.user.firstName = firstNameField.text
        self.user.lastName = lastNameField.text
        self.user.phone = phoneField.text
        self.user.email = emailField.text
        
        if oldPhoneNumber == phoneField.text {
            SVProgressHUD.show()
            updateProfile(person: user) { error in
                if let error = error {
                    print("EditProfileVC Error updating profile: \(error.localizedDescription)")
                    SVProgressHUD.showError(withStatus: "An error occured updating your profile, please try again.")
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
        } else {
            requestPhoneNumberRegisteration(phoneNumber: phoneField.text!, deviceUniqueId: self.deviceUniqueId)
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
                    
                    self.navigateToPrevScreen()
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
                
                self.navigateToPrevScreen()
            })
        }

    }
}

// MARK: - Event Handlers

extension EditProfileVC {
    
    @IBAction func changePicButtonPressed(_ sender: AnyObject) {
        view.endEditing(true)
        present(choosePictureMenu, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        performSaveProfileUpdates()
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - UIImagePickerControllerDelegate Implementation

extension EditProfileVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            selectedProfilePicture = image
            profilePicImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UINavigationControllerDelegate Implementation

extension EditProfileVC: UINavigationControllerDelegate { }

// MARK: - Networking

extension EditProfileVC {
    
    func requestPhoneNumberRegisteration(phoneNumber: String, deviceUniqueId: String) {
        SVProgressHUD.show()
        let registerPhoneReq = RegisterPhoneRequest.init(phoneNumber: phoneNumber, deviceUniqueId: deviceUniqueId)
        let _ = networkSession?.send(registerPhoneReq) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                print("Successful phone number registration API call.")
                self.performSegue(withIdentifier: "showVerifyPhoneNumberVC", sender: self)
            case .failure(let error):
                print("RegisterPhoneRequest error: \(error)")
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
