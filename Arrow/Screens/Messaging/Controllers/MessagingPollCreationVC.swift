
import UIKit

protocol MessagingPollCreationDelegate {
    func didCompleteCreatingPoll(poll:ARPoll)
    func didCancelCreatingPoll()
}
final class MessagingPollCreationVC: ARKeyboardViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.messagingPollCreation()
    static var kStoryboardIdentifier: String? = "MessagingPollCreationVC"

    @IBOutlet weak var titleTextField: ARFormTextField!
    @IBOutlet weak var descriptionTextField: ARFormTextField!
    @IBOutlet weak var createPollButton: ARButton!
    @IBOutlet weak var inputAccessoryCreatePollButton: ARButton!

    @IBOutlet weak var optionstableView: UITableView!
    fileprivate var imagePickerController: UIImagePickerController?
    fileprivate var choosePictureMenu: UIAlertController?

    var delegate: MessagingPollCreationDelegate?
    var selectedOption: Int?
    var options = [ARPollOption]()
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = optionstableView
        self.setupView()
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



    private func setupChoosePictureMenu() {
        let photoLibraryItem = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.showImagePicker(type: .photoLibrary)
        }
        choosePictureMenu?.addAction(photoLibraryItem)
        let cameraItem = UIAlertAction(title: "Take Photo", style: .default) { action in
            self.showImagePicker(type: .camera)
        }
        choosePictureMenu?.addAction(cameraItem)
        let cancelItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        choosePictureMenu?.addAction(cancelItem)
    }

    private func setupImagePicker() {
        imagePickerController?.allowsEditing = true
        imagePickerController?.delegate = self
    }

    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }

        imagePickerController?.sourceType = type
        if let imagePickerController = self.imagePickerController {
            present(imagePickerController, animated: true, completion: nil)
        }
    }

}

extension MessagingPollCreationVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton

        let resetBarButton = UIBarButtonItem(title: "RESET", style: .done, target: self, action: #selector(resetButtonPressed(_:)))
        cancelBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .normal)
        resetBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .normal)
        navigationItem.leftBarButtonItem = resetBarButton
        self.resetFields()
        self.createPollButton.disabledBackgroundColor = R.color.arrowColors.paleGray()
        self.createPollButton.setTitleColor(R.color.arrowColors.hathiGray(), for: .disabled)
        self.createPollButton.isEnabled = self.checkFields()
        self.titleTextField.textField.autocapitalizationType = .sentences
    }

    fileprivate func resetFields() {
        self.titleTextField.text = ""
        self.options = []
        for _ in 0..<2 {
            options.append(ARPollOption(identifier: UUID().uuidString))
        }
        optionstableView.reloadData()
    }
    fileprivate func checkFields() -> Bool {
        guard let text = self.titleTextField.text else {
            return false
        }
        if text.isEmpty {
            return false
        }
        for option in self.options {
            if let optionText = option.text, !optionText.isEmpty {

            } else {
                return false
            }
        }
        return true
    }
}
// MARK: - Event Handlers

extension MessagingPollCreationVC {

        @IBAction func cancelButtonPressed(_ sender: AnyObject) {
            self.delegate?.didCancelCreatingPoll()
        }

        @IBAction func resetButtonPressed(_ sender: AnyObject) {
            self.resetFields()
        }

        @IBAction func didPressCreatePoll(_ sender: Any) {
            var poll = ARPoll()
            poll.options = self.options
            poll.question = self.titleTextField.text
            self.delegate?.didCompleteCreatingPoll(poll: poll)
        }
}

extension MessagingPollCreationVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage, let selectedOption = self.selectedOption {
            self.options[selectedOption].image = image

        }

        dismiss(animated: true, completion: nil)
        self.optionstableView.reloadData()
    }

}

extension MessagingPollCreationVC: UINavigationControllerDelegate { }
extension MessagingPollCreationVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return options.count
        } else {
            return 1
        }


    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell: PollOptionTableViewCell?
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pollOptionTableViewCell, for: indexPath)
            let option = options[indexPath.row]
            cell?.row = indexPath.row
            cell?.setupCell(option: option)
            cell?.delegate = self

            return cell ?? UITableViewCell()
        } else {
            var cell: PollNewOptionTableViewCell?
            cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.pollNewOptionTableViewCell, for: indexPath)
            cell?.delegate = self

            return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 52.0
        } else {
            return 75.0
        }
    }



}

extension MessagingPollCreationVC: UITableViewDelegate {


}

extension MessagingPollCreationVC: PollOptionTableViewCellDelegate {
    func didUpdateText(text: String?, row: Int) {
        print("textupdated \(String(describing: text))")
        self.options[row].text = text
        self.createPollButton.isEnabled = self.checkFields()
    }
    func didUpdateImage(image: UIImage?, row:Int) {
        self.options[row].image = image

    }
    func didTapCamera(row:Int) {
        if let choosePictureMenu = self.choosePictureMenu {
            self.selectedOption = row
            self.present(choosePictureMenu, animated: true, completion: nil)
        }
    }
    func didDeleteOption(row:Int) {
        self.options[row].image = nil
        self.optionstableView.reloadData()
    }
}

extension MessagingPollCreationVC: PollNewOptionTableViewCellDelegate {
    func didAddNewOption() {
        options.append(ARPollOption(identifier: UUID().uuidString))
        optionstableView.reloadData()
    }
}

protocol PollOptionTableViewCellDelegate {
    func didUpdateText(text:String?, row:Int)
    func didUpdateImage(image:UIImage?, row:Int)
    func didTapCamera(row:Int)
    func didDeleteOption(row:Int)
}
class PollOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!

    var delegate: PollOptionTableViewCellDelegate?
    var row: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        textTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textTextField.delegate = self
    }

    func setupCell(option: ARPollOption) {
        self.textTextField.text = option.text
        if let image = option.image {
            self.cameraButton.isHidden = true
            self.photoImageView.isHidden = false
            self.photoImageView.image = image
            self.deleteButton.isHidden = false
        } else {
            self.photoImageView.isHidden = true
            self.cameraButton.isHidden = false
            self.photoImageView.image = nil
            self.deleteButton.isHidden = true
        }
    }

    @IBAction func deleteAction(_ sender: Any) {
        if let row = self.row {
            delegate?.didDeleteOption(row: row)
        }
    }
    @IBAction func takePictureAction(_ sender: Any) {
        if let row = self.row {
            delegate?.didTapCamera(row: row)
        }
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if let row = self.row {
            delegate?.didUpdateText(text:textField.text, row:row)
        }
    }

}

extension PollOptionTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
protocol PollNewOptionTableViewCellDelegate {
    func didAddNewOption()
}

class PollNewOptionTableViewCell: UITableViewCell {

    var delegate: PollNewOptionTableViewCellDelegate?
    var row: Int?

    @IBOutlet weak var optionButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.optionButton.layer.cornerRadius = 5.0
        self.optionButton.layer.borderWidth = 4.0
        self.optionButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
    }

    @IBAction func newOptionTapped(_ sender: Any) {
        self.delegate?.didAddNewOption()
    }
}

struct ARPoll {

    var question: String?
    var options: [ARPollOption]?
}

// MARK: - Dictionariable Implementation

extension ARPoll: Dictionariable {
    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var question = "question"
        static var options = "options"
    }
    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }

        question = dictionary[Keys.question] as? String
        if let dicts = dictionary[Keys.options] as? [Dictionary<String, Any>] {
            options = dicts.flatMap { ARPollOption(with: $0) }
        }
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.question: question,
            Keys.options: options?.dictionaryRepresentation()
        ]
        return dict.nilsRemoved()
    }
}
struct ARPollOption {

    var identifier: String?
    var text: String?
    var image: UIImage?
    var imageUrl: URL?
    var votes: [String:Bool]?

}

// MARK: - Dictionariable Implementation

extension ARPollOption: Dictionariable {

    /// Dictionary keys.
    struct Keys {
        static var identifier = "id"
        static var text = "text"
        static var image = "image"
        static var imageUrl = "imageUrl"
        static var votes = "votes"
    }
    init(identifier: String) {
        self.identifier = identifier
    }

    init?(with dictionary: Dictionary<String, Any>?) {
        guard let dictionary = dictionary else {
            return nil
        }

        identifier = dictionary[Keys.identifier] as? String

        text = dictionary[Keys.text] as? String

        if let urlString = dictionary[Keys.imageUrl] as? String {
            imageUrl = URL(string: urlString)
        }
        votes = dictionary[Keys.votes] as? [String:Bool]
    }

    func dictionaryRepresentation() -> Dictionary<String, Any> {
        let dict: [String: Any?] = [
            Keys.identifier: identifier,
            Keys.text: text,
            Keys.imageUrl: imageUrl?.absoluteString,
            Keys.votes: votes
        ]
        return dict.nilsRemoved()
    }

}
