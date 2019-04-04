
import UIKit

final class CreateBubbleVC: ARKeyboardViewController, NibViewController, ARForm {
    
    static var kNib: UINib = R.nib.createBubble()
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var choosePictureButton: UIButton!
    @IBOutlet weak var addImageLabel: UILabel!
    @IBOutlet weak var titleTextField: ARFormTextField!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    // Unused ARForm members.
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var inputAccessoryActionButton: UIButton!
    
    var allFormFields = [ARFormTextField]() {
        didSet {
            let _ = allFormFields.map {
                $0.textFieldDelegate = self
                $0.textField.addTarget(self, action: #selector(requiredTextFieldDidChange(_:)), for: .editingChanged)
            }
        }
    }
    var requiredFormFields = [ARFormTextField]()
    
    fileprivate var choosePictureMenu: UIAlertController!
    fileprivate var imagePickerController: UIImagePickerController!
    
    var selectedPicture: UIImage? {
        didSet {
            pictureImageView.image = selectedPicture ?? R.image.blueGradientRectangle()
            addImageLabel?.isHidden = selectedPicture != nil
        }
    }
    
    var delegate: CreateBubbleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Create A New Bubble"
        setupView()
        formSetup()
        setLocalizableStrings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Delay initializations for performant view appearance.
        if imagePickerController == nil {
            imagePickerController = UIImagePickerController()
            setupImagePicker()
        }
        
        if choosePictureMenu == nil {
            choosePictureMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            setupChoosePictureMenu()
        }
        
        let _ = titleTextField.becomeFirstResponder()
    }
    
}

// MARK: - UI Helpers

extension CreateBubbleVC {
    
    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.leftBarButtonItem = cancelBarButton
        
        let nextBarButton = UIBarButtonItem(title: "NEXT", style: .done, target: self, action: #selector(nextButtonPressed(_:)))
        nextBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .disabled)
        nextBarButton.setTitleTextColor(R.color.arrowColors.waterBlue(), for: .normal)
        self.nextBarButton = nextBarButton
        navigationItem.rightBarButtonItem = nextBarButton
        
        // Picture image view.
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.clipsToBounds = true
        pictureImageView.layer.cornerRadius = 5.0
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
    
    fileprivate func setLocalizableStrings() { }
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func updateActionButtonState() {
        let allNonEmpty = allFormFields.reduce(true) {
            let isEmpty = $1.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            return $0 && !isEmpty
        }
        nextBarButton.isEnabled = allNonEmpty
    }
    
    fileprivate func navigateToMembersScreen() {
        guard let bubbleName = titleTextField.text else {
            return
        }
        
        let addBubbleMembersVC = AddBubbleMembersVC.instantiate()
        addBubbleMembersVC.delegate = self
        addBubbleMembersVC.bubble = ARBubble(title: bubbleName, picture: selectedPicture)
        navigationController?.pushViewController(addBubbleMembersVC, animated: true)
    }
    
}

// MARK: - ARForm Implementation

extension CreateBubbleVC {
    
    func formSetup() {
        allFormFields = [titleTextField]
        requiredFormFields = allFormFields
        
        // Setup form fields.
        titleTextField.setup(placeholder: "Name your bubble...", keyboardType: .asciiCapable, autoCapitalization: true)
        titleTextField.textField.autocapitalizationType = .words
        titleTextField.textFont = R.font.alegreyaSansBold(size: 24.0)!
        
        updateActionButtonState()
    }
    
}

// MARK: - Event Handlers

extension CreateBubbleVC {
    
    @IBAction func choosePictureButtonPressed(_ sender: AnyObject) {
        present(choosePictureMenu, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createBubbleDidCancel(controller: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        navigateToMembersScreen()
    }
    
    @IBAction func requiredTextFieldDidChange(_ textField: UITextField) {
        updateActionButtonState()
    }
    
}

// MARK: - UIImagePickerControllerDelegate Implementation

extension CreateBubbleVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            selectedPicture = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UINavigationControllerDelegate Implementation

extension CreateBubbleVC: UINavigationControllerDelegate { }

// MARK: - UITextFieldDelegate Implementation

extension CreateBubbleVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - Add Bubble Members Delegate Implementation

extension CreateBubbleVC: AddBubbleMembersDelegate {
    
    func addBubbleMembersDidCancel(controller: AddBubbleMembersVC) {
        delegate?.createBubbleDidCancel(controller: self)
    }
    
    func addBubbleMembersDidComplete(controller: AddBubbleMembersVC, bubble: ARBubble) {
        delegate?.createBubbleDidComplete(controller: self, bubble: bubble)
    }
    
}

// MARK: - Create Bubble Delegate Definition

protocol CreateBubbleDelegate {
    func createBubbleDidCancel(controller: CreateBubbleVC)
    func createBubbleDidComplete(controller: CreateBubbleVC, bubble: ARBubble)
}
