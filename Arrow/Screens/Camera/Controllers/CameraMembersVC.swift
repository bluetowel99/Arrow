
import UIKit

final class CameraMembersVC: ARKeyboardViewController, NibViewController {
    
    static var kNib: UINib = R.nib.cameraMembers()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var nextBarButton: UIBarButtonItem!
    
    // MARK: Public Properties
    
    var capturedMediaInfo: CapturedMediaInfo?
    
    // MARK: Private Properties
    
    fileprivate lazy var phonePicker = { PhonePickerPopoverVC.instantiate() }()
    
    fileprivate var selectedMembers = Dictionary<String, ARPerson>() {
        didSet {
            nextBarButton?.isEnabled = !selectedMembers.isEmpty
        }
    }
    fileprivate var _localContacts = Array<ARContactStore.LocalContactInfo>() {
        didSet {
            filterContacts(string: searchTextField.text)
        }
    }
    fileprivate var filteredLocalContacts = Array<ARContactStore.LocalContactInfo>() {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    // MARK: Delegate
    
    var delegate: DismissableControllerDelegate?
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Share With"
        setupView()
        setLocalizableStrings()
        setupTableView()
        loadLocalContacts()
    }
    
}

// MARK: - UI Helpers

extension CameraMembersVC {
    
    fileprivate func setupView() {
        // Navigation bar buttons.
        let nextBarButton = UIBarButtonItem(title: "NEXT", style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
        nextBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .disabled)
        nextBarButton.setTitleTextColor(R.color.arrowColors.waterBlue(), for: .normal)
        nextBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextBarButton
        self.nextBarButton = nextBarButton
        
        // Search text field.
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextFieldChanged(_:)), for: .editingChanged)
    }
    
    fileprivate func setLocalizableStrings() { }
    
    fileprivate func setupTableView() {
        scrollView = tableView
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.rowHeight = BubbleMemberCell.rowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.bubbleMemberCell)
    }
    
    fileprivate func loadLocalContacts() {
        platform.contactStore.fetchLocalContacts(forceRefresh: false) { contacts in
            self._localContacts = contacts ?? Array<ARContactStore.LocalContactInfo>()
        }
    }
    
    fileprivate func filterContacts(string: String?) {
        guard let string = string?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            string.isEmpty == false else {
                filteredLocalContacts = _localContacts
                return
        }
        
        // Filter local contacts.
        filteredLocalContacts = _localContacts.filter {
            return $0.person.firstName?.lowercased().hasPrefix(string) ?? false ||
                $0.person.lastName?.lowercased().hasPrefix(string) ?? false
        }
    }
    
    fileprivate func showPhonePicker(for contact: ARContactStore.LocalContactInfo) {
        phonePicker.setupPicker(for: contact)
        phonePicker.delegate = self
        phonePicker.modalPresentationStyle = .overCurrentContext
        phonePicker.modalTransitionStyle = .coverVertical
        present(phonePicker, animated: true, completion: nil)
    }
    
    fileprivate func navigateToConfirmationScreen() {
        let cameraConfirmVC = CameraConfirmVC.instantiate()
        capturedMediaInfo?.selectedMembers = selectedMembers
        cameraConfirmVC.capturedMediaInfo = capturedMediaInfo
        cameraConfirmVC.delegate = delegate
        
        navigationController?.pushViewController(cameraConfirmVC, animated: true)
    }
    
}

// MARK: - Logic Helpers

extension CameraMembersVC {
    
    fileprivate func select(contact: ARPerson) {
        guard let identifier = contact.identifier else {
            return
        }
        
        var indexPath: IndexPath?
        for index in 0..<filteredLocalContacts.count {
            if filteredLocalContacts[index].person.identifier == identifier {
                indexPath = IndexPath(item: index, section: 0)
                break
            }
        }
        
        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath) as? BubbleMemberCell
            cell?.mode = .checked
            selectedMembers[identifier] = contact
        }
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension CameraMembersVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLocalContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bubbleMemberCell, for: indexPath)
        
        let contactInfo = filteredLocalContacts[indexPath.row]
        memberCell?.setupCell(person: contactInfo.person)
        if let identifier = contactInfo.person.identifier {
            memberCell?.mode = selectedMembers[identifier] != nil ? .checked : .unchecked
        }
        
        return memberCell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension CameraMembersVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BubbleMemberCell else {
            return
        }
        
        if cell.mode == .checked {
            cell.mode = .unchecked
            if let identifier = cell.person.identifier {
                selectedMembers.removeValue(forKey: identifier)
            }
        } else {
            var contactInfo = filteredLocalContacts[indexPath.row]
            if contactInfo.phoneNumbers.count > 1 {
                showPhonePicker(for: contactInfo)
            } else {
                contactInfo.person.phone = contactInfo.phoneNumbers.first?.number
                select(contact: contactInfo.person)
            }
        }
    }
    
}

// MARK: - Event Handlers

extension CameraMembersVC {
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        navigateToConfirmationScreen()
    }
    
    @objc func searchTextFieldChanged(_ textField: UITextField) {
        guard let searchString = textField.text else {
            return
        }
        
        filterContacts(string: searchString)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension CameraMembersVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - PhonePickerPopover Delegate Implementation

extension CameraMembersVC: PhonePickerPopoverDelegate {
    
    func phonePickerPopoverDidDismiss(controller: PhonePickerPopoverVC) {
        dismiss(animated: true, completion: nil)
    }
    
    func phonePickerPopoverDidSelect(controller: PhonePickerPopoverVC, selection: ARContactStore.LocalContactInfo) {
        select(contact: selection.person)
        dismiss(animated: true, completion: nil)
    }
    
}
