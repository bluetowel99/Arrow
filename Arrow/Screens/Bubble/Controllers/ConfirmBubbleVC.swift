
import UIKit
import Contacts

final class ConfirmBubbleVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.confirmBubble()
    
    @IBOutlet weak var nameTextField: ARFormTextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameEditButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var pictureEditButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: ARButton!
    @IBOutlet weak var inputAccessoryCreateButton: ARButton!
    
    fileprivate var choosePictureMenu: UIAlertController!
    fileprivate var imagePickerController: UIImagePickerController!
    fileprivate var selectedPicture: UIImage? {
        didSet {
            pictureImageView.image = selectedPicture ?? R.image.blueGradientRectangle()
        }
    }
    fileprivate var bubbleMembers = [ARPerson]()
    
    var bubble: ARBubble? {
        didSet {
            bubbleMembers = bubble?.members ?? [ARPerson]()
            tableView.reloadData()
            updateBubbleInfo()
        }
    }
    var delegate: ConfirmBubbleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Confirm Bubble"
        setupView()
        setLocalizableStrings()
        setupTableView()
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
    }
    
}

// MARK: - UI Helpers

extension ConfirmBubbleVC {
    
    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton
        
        // Name text field.
        nameTextField.setup(placeholder: "Name your bubble...", keyboardType: .asciiCapable, autoCapitalization: true)
        nameTextField.textField.autocapitalizationType = .words
        nameTextField.textColor = R.color.arrowColors.marineBlue()
        nameTextField.textFont = R.font.workSansBlack(size: 24.0)!
        nameTextField.textField.inputAccessoryView = inputAccessoryCreateButton
        nameTextField.textField.delegate = self
        
        // Picture image view.
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.clipsToBounds = true
        pictureImageView.layer.cornerRadius = 5.0
        
        // Submit buttons.
        let _ = [createButton, inputAccessoryCreateButton].map {
            $0?.borderWidth = 0.0
            $0?.disabledBackgroundColor = R.color.arrowColors.paleGray()
            $0?.setTitleColor(R.color.arrowColors.hathiGray(), for: .disabled)
        }
    }
    
    fileprivate func setLocalizableStrings() { }
    
    fileprivate func setupTableView() {
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.rowHeight = BubbleMemberCell.rowHeight
        tableView.dataSource = self
        tableView.register(R.nib.bubbleMemberCell)
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
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func updateBubbleInfo() {
        nameLabel.text = bubble?.title
        nameTextField.text = bubble?.title
        updateNameEditingMode(editing: false)
        pictureImageView.image = bubble?.picture ?? R.image.blueGradientRectangle()
    }
    
    fileprivate func updateNameEditingMode(editing: Bool) {
        nameLabel.isHidden = editing
        nameEditButton.isHidden = editing
        nameTextField.isHidden = editing == false
    }
    
    fileprivate func createBubble() {
        guard var bubble = bubble else {
            assertionFailure("Bubble has not been set.")
            return
        }
        
        if let newName = nameTextField.text {
            bubble.title = newName
        }
        
        if let newPicture = selectedPicture {
            bubble.picture = newPicture
        }
        
        createBubble(bubble: bubble) { bubble, error in
            if let error = error {
                print("Error calling Create Bubble API")
                print(error.localizedDescription)
            } else {
                if let bubble = bubble {
                    self.delegate?.confirmBubbleDidComplete(controller: self, bubble: bubble)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension ConfirmBubbleVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bubbleMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bubbleMemberCell, for: indexPath)
        
        let member = bubbleMembers[indexPath.row]
        memberCell?.setupCell(person: member)
        memberCell?.mode = .deleteButton
        memberCell?.delegate = self
        
        return memberCell ?? UITableViewCell()
    }
    
}

// MARK: - Event Handlers

extension ConfirmBubbleVC {
    
    @IBAction func createButtonPressed(_ sender: AnyObject) {
        // Check edited bubble name is not empty.
        if nameTextField.isHidden == false && nameTextField.text?.isEmpty == true {
            nameTextField.show(errorMessage: " ")
            return
        }
        
        createBubble()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.confirmBubbleDidCancel(controller: self)
    }
    
    @IBAction func editNameButtonPressed( _ sender: AnyObject) {
        updateNameEditingMode(editing: true)
        nameTextField.textField.becomeFirstResponder()
    }
    
    @IBAction func editingPictureButtonPressed(_ sender: AnyObject) {
        present(choosePictureMenu, animated: true, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension ConfirmBubbleVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - BubbleMemberCellDelegate Implementation

extension ConfirmBubbleVC: BubbleMemberCellDelegate {
    
    func bubbleMemberCellDidPressDelete(cell: BubbleMemberCell, for person: ARPerson) {
        guard let index = (bubbleMembers.index { $0.identifier == person.identifier }) else {
            print("Could not delete row for \(String(describing: person.displayName()))")
            return
        }
        
        bubbleMembers.remove(at: index)
        tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .top)
    }
    
}

// MARK: - UIImagePickerControllerDelegate Implementation

extension ConfirmBubbleVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            selectedPicture = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UINavigationControllerDelegate Implementation

extension ConfirmBubbleVC: UINavigationControllerDelegate { }

// MARK: - Networking

extension ConfirmBubbleVC {
    
    fileprivate func createBubble(bubble: ARBubble, callback: ((ARBubble?, Error?) -> Void)?) {
        let createBubbleReq = CreateBubbleRequest(platform: platform, bubble: bubble)
        let _ = networkSession?.send(createBubbleReq) { result in
            switch result {
            case .success(let bubble):
                callback?(bubble, nil)
            case .failure(let error):
                callback?(nil, error)
            }
        }
    }
    
}

// MARK: - Confirm Bubble Delegate Definition

protocol ConfirmBubbleDelegate {
    func confirmBubbleDidCancel(controller: ConfirmBubbleVC)
    func confirmBubbleDidComplete(controller: ConfirmBubbleVC, bubble: ARBubble)
}
