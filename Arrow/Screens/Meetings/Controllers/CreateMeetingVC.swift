
import UIKit

final class CreateMeetingVC: ARKeyboardViewController, StoryboardViewController, ARForm {

    static var kStoryboard: UIStoryboard = R.storyboard.createMeeting()
    static var kStoryboardIdentifier: String? = "CreateMeetingVC"

    @IBOutlet weak var titleTextField: ARFormTextField!
    @IBOutlet weak var descriptionTextField: ARFormTextField!
    @IBOutlet weak var setLocationButton: ARButton!
    @IBOutlet weak var inputAccessorySetLocationButton: ARButton!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var inputAccessoryActionButton: UIButton!

    var bubble: ARBubble?

    var allFormFields = [ARFormTextField]() {
        didSet {
            let _ = allFormFields.map {
                $0.textFieldDelegate = self
                $0.textField.addTarget(self, action: #selector(requiredTextFieldDidChange(_:)), for: .editingChanged)
            }
        }
    }
    var requiredFormFields = [ARFormTextField]()

    var delegate: CreateMeetingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "New Meet Spot"
        setupView()
        formSetup()
    }
    @IBAction func setLocationButtonPressed(_ sender: AnyObject) {
        let meetingLocationVC = MeetingLocationVC.instantiate()
        guard let title = self.titleTextField.text, let bubble = self.bubble else {
            print("ERROR: Bubble and/or Title data not sent to CreateMeetingVC")
            return
        }
        let description = self.descriptionTextField.text
        meetingLocationVC.delegate = self.delegate
        meetingLocationVC.meeting = ARMeeting(identifier: 0, bubbleId: bubble.identifier, title: title, description: description, date: Date(), locationId: nil, longitude: 0, latitude: 0, rsvps: [])
        navigationController?.pushViewController(meetingLocationVC, animated: true)
    }
}

// MARK: - UI Helpers

extension CreateMeetingVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton

        let resetBarButton = UIBarButtonItem(title: "RESET", style: .done, target: self, action: #selector(resetButtonPressed(_:)))
        navigationItem.leftBarButtonItem = resetBarButton

        // Submit buttons.
        let _ = [setLocationButton, inputAccessorySetLocationButton].map {
            $0?.borderWidth = 0.0
            $0?.disabledBackgroundColor = R.color.arrowColors.paleGray()
            $0?.setTitleColor(R.color.arrowColors.hathiGray(), for: .disabled)
        }
    }

    fileprivate func updateActionButtonState() {
        let allNonEmpty = allFormFields.reduce(true) {
            let isEmpty = $1.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
            return $0 && !isEmpty
        }
        actionButton.isEnabled = allNonEmpty
    }

    fileprivate func resetForm() {
        titleTextField.text = nil
    }

}

// MARK: - ARForm Implementation

extension CreateMeetingVC {

    func formSetup() {
        actionButton = setLocationButton

        allFormFields = [titleTextField, descriptionTextField]
        requiredFormFields = allFormFields

        // Setup form fields.
        titleTextField.setup(placeholder: "Give it a title...", keyboardType: .asciiCapable, autoCapitalization: true)
        titleTextField.textField.autocapitalizationType = .words
        titleTextField.textFont = R.font.alegreyaSansBold(size: 20.0)!

        descriptionTextField.setup(placeholder: "Add a description...", keyboardType: .asciiCapable, autoCapitalization: true)
        descriptionTextField.textField.autocapitalizationType = .sentences
        descriptionTextField.textFont = R.font.alegreyaSansBold(size: 20.0)!

        updateActionButtonState()
        
        let _ = titleTextField.becomeFirstResponder()
    }

}


// MARK: - Event Handlers

extension CreateMeetingVC {

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createMeetingDidCancel(controller: self)
    }

    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        resetForm()
    }

    @IBAction func requiredTextFieldDidChange(_ textField: UITextField) {
        updateActionButtonState()
    }

}

// MARK: - UINavigationControllerDelegate Implementation

extension CreateMeetingVC: UINavigationControllerDelegate { }

// MARK: - UITextFieldDelegate Implementation

extension CreateMeetingVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

// MARK: - Create Meeting Delegate Definition

protocol CreateMeetingDelegate {
    func createMeetingDidCancel(controller: UIViewController)
    func createMeetingDidComplete(controller: UIViewController, meeting: ARMeeting)
}
