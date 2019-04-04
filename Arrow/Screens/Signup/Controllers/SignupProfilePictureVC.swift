
import UIKit

final class SignupProfilePictureVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.signupProfilePicture()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var choosePictureButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    let choosePictureMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let imagePickerController = UIImagePickerController()
    var selectedProfilePicture: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Create Your Profile"
        setupView()
        setupChoosePictureMenu()
        setupImagePicker()
        setLocalizableStrings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.width / 2.0
    }
    
}

// MARK: - UI Helpers

extension SignupProfilePictureVC {
    
    fileprivate func setupView() {
        profilePictureImageView.contentMode = .scaleAspectFill
        profilePictureImageView.clipsToBounds = true
        nameLabel.text = platform.userSession?.user?.displayName()
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
    
    fileprivate func setLocalizableStrings() {
        nextButton.setTitle(R.string.signup.verifyCodeNextButtonTitle(), for: .normal)
    }
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func navigateToPermissionScreen() {
        let permissionsVC = SignupPermissionsVC.instantiate()
        navigationController?.pushViewController(permissionsVC, animated: true)
    }
    
}

// MARK: - Logic Helpers

extension SignupProfilePictureVC {
    
    fileprivate func performProfilePictureUpload(using selectedImage: UIImage) {
        uploadProfilePicture(image: selectedImage) { error in
            if let error = error {
                print("Error uploading user profile picture:\n\(error)")
                return
            }
            
            self.performUserProfileRefresh()
        }
    }
    
    fileprivate func performUserProfileRefresh() {
        platform.refreshUserProfile(networkSession: networkSession) { error in
            if let error = error {
                print("Error fetching latest user profile: \(error)")
                return
            }
            
            self.navigateToPermissionScreen()
        }
    }
    
}

// MARK: - Event Handlers

extension SignupProfilePictureVC {
    
    @IBAction func choosePictureButtonPressed(_ sender: AnyObject) {
        present(choosePictureMenu, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        guard let selectedProfilePicture = selectedProfilePicture else {
            navigateToPermissionScreen()
            return
        }
        
        self.performProfilePictureUpload(using: selectedProfilePicture)
    }
    
}

// MARK: - UIImagePickerControllerDelegate Implementation

extension SignupProfilePictureVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            selectedProfilePicture = image
            profilePictureImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UINavigationControllerDelegate Implementation

extension SignupProfilePictureVC: UINavigationControllerDelegate { }

// MARK: - Networking

extension SignupProfilePictureVC {
    
    fileprivate func uploadProfilePicture(image: UIImage, callback: ((NSError?) -> Void)?) {
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
    
    fileprivate func fetchProfile(callback: ((ARPerson?, NSError?) -> Void)?) {
        let getMyProfileReq = GetMyProfileRequest()
        let _ = networkSession?.send(getMyProfileReq) { result in
            switch result {
            case .success(let me):
                callback?(me, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}
