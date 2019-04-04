
import UIKit

final class MessagingAddContacts: ARKeyboardViewController, NibViewController {

    static var kNib: UINib = R.nib.messagingAddContacts()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!

    fileprivate lazy var phonePicker = { PhonePickerPopoverVC.instantiate() }()

    fileprivate var searchQuery: String?

    fileprivate var selectedMembers = Dictionary<String, ARPerson>() {
        didSet {
            nextBarButton.isEnabled = selectedMembers.isEmpty == false
        }
    }
    fileprivate private(set) var _localContacts = Array<ARContactStore.LocalContactInfo>() {
        didSet {
            filterContacts(string: searchQuery)
        }
    }
    fileprivate var filteredLocalContacts = Array<ARContactStore.LocalContactInfo>() {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(CGPoint(x: 0.0, y: -tableView.contentInset.top), animated: true)
        }
    }

    var delegate: AddBContactsMembersDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Select Contacts"
        setupView()
        setLocalizableStrings()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Deferred initial local contact loading for view's enhanced appearance performance.
        if _localContacts.count == 0 {
            platform.contactStore.fetchLocalContacts(forceRefresh: false) { contacts in
                self._localContacts = contacts ?? Array<ARContactStore.LocalContactInfo>()
            }
        }
    }

}

// MARK: - UI Helpers

extension MessagingAddContacts {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let nextBarButton = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
        nextBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .disabled)
        nextBarButton.setTitleTextColor(R.color.arrowColors.waterBlue(), for: .normal)
        nextBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextBarButton
        self.nextBarButton = nextBarButton

        let backBarButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(navigationBackButtonPressed(_:)))
        navigationItem.leftBarButtonItem = backBarButton
    }

    fileprivate func setLocalizableStrings() { }

    fileprivate func setupTableView() {
        scrollView = tableView
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = BubbleMemberCell.rowHeight
        tableView.contentInset = UIEdgeInsets(top: 8.0, left: 0, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(R.nib.messagesContactCell)
        tableView.register(R.nib.searchBarCell)
        tableView.register(R.nib.simpleSectionHeader(), forHeaderFooterViewReuseIdentifier: SimpleSectionHeader.reuseIdentifier)
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

}

// MARK: - Logic Helpers

extension MessagingAddContacts {

    fileprivate func select(contact: ARPerson) {
        guard let identifier = contact.identifier else {
            return
        }

        var indexPath: IndexPath?
        for index in 0..<filteredLocalContacts.count {
            if filteredLocalContacts[index].person.identifier == identifier {
                indexPath = IndexPath(item: index, section: 1)
                break
            }
        }

        if let indexPath = indexPath {
            let cell = tableView.cellForRow(at: indexPath) as? MessagesContactCell
            cell?.mode = .checked
            selectedMembers[identifier] = contact
        }
    }

}

// MARK: - UITableViewDataSource Implementation

extension MessagingAddContacts: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return filteredLocalContacts.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return getSearchCell(indexPath: indexPath)
        case 1:
            return getMemberCell(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }

    fileprivate func getSearchCell(indexPath: IndexPath) -> UITableViewCell {
        let searchCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchBarCell, for: indexPath)

        searchCell?.setup(icon: R.image.search(), placeholderText: "Search", searchText: searchQuery, inputAccessoryView: nil)
        searchCell?.delegate = self

        return searchCell ?? UITableViewCell()
    }

    fileprivate func getMemberCell(indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagesContactCell, for: indexPath)

        let contactInfo = filteredLocalContacts[indexPath.row]
        memberCell?.setupCell(person: contactInfo.person)
        if let identifier = contactInfo.person.identifier {
            memberCell?.mode = selectedMembers[identifier] != nil ? .checked : .unchecked
        }

        return memberCell ?? UITableViewCell()
    }

}

// MARK: - UITableViewDelegate Implementation

extension MessagingAddContacts: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seach bar selected.
        if let cell = tableView.cellForRow(at: indexPath) as? SearchBarCell {
            cell.textField.becomeFirstResponder()
        }

        // Member row selected.
        guard let cell = tableView.cellForRow(at: indexPath) as? MessagesContactCell else {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return SearchBarCell.rowHeight
        default:
            return BubbleMemberCell.rowHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        func dequeueReusableSectionHeader(title: String, showMore: Bool) -> SimpleSectionHeader? {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SimpleSectionHeader.reuseIdentifier) as? SimpleSectionHeader
            header?.setupHeader(title: title)

            return header
        }

        switch section {
        case 1:
            return dequeueReusableSectionHeader(title: "CONTACTS", showMore: false)
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return SimpleSectionHeader.height
        default:
            return 0.0
        }
    }

}

// MARK: - Event Handlers

extension MessagingAddContacts {

    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        self.delegate?.addContactsDidComplete(controller: self, users: self.selectedMembers)
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - PhonePickerPopover Delegate Implementation

extension MessagingAddContacts: PhonePickerPopoverDelegate {

    func phonePickerPopoverDidDismiss(controller: PhonePickerPopoverVC) {
        dismiss(animated: true, completion: nil)
    }

    func phonePickerPopoverDidSelect(controller: PhonePickerPopoverVC, selection: ARContactStore.LocalContactInfo) {
        select(contact: selection.person)
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - SearchBarCellDelegate Implementation

extension MessagingAddContacts: SearchBarCellDelegate {

    func searchBarCell(searchBarCell: SearchBarCell, textDidChange text: String?) {
        searchQuery = searchBarCell.textField.text

        guard let searchString = text else {
            return
        }

        filterContacts(string: searchString)
    }

}

protocol AddBContactsMembersDelegate {
    func addContactsDidComplete(controller: MessagingAddContacts, users: Dictionary<String, ARPerson>)
}


