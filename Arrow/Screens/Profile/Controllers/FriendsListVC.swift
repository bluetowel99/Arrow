
import UIKit

final class FriendsListVC: ARKeyboardViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.friendsList()
    static var kStoryboardIdentifier: String? = "FriendsListVC"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var addFriendsButton: ARButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Private Properties
    
    fileprivate var _arrowContacts = Array<ARPerson>() {
        didSet {
            filterContacts(string: searchTextField.text)
        }
    }
    fileprivate var filteredArrowContacts = Array<ARPerson>() {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Friends"
        setupView()
        setLocalizableStrings()
        setupTableView()
        loadArrowContacts()
    }
    
}

// MARK: - UI Helpers

extension FriendsListVC {
    
    fileprivate func setupView() {
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
    
    fileprivate func loadArrowContacts() {
        platform.contactStore.fetchArrowContacts(forceRefresh: false, platform: platform, networkSession: networkSession) { contacts in
            if let contacts = contacts {
                self._arrowContacts = contacts
            }
        }
    }
    
    fileprivate func filterContacts(string: String?) {
        guard let string = string?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            string.isEmpty == false else {
                filteredArrowContacts = _arrowContacts
                return
        }
        
        // Filter local contacts.
        filteredArrowContacts = _arrowContacts.filter {
            return $0.firstName?.lowercased().hasPrefix(string) ?? false ||
                $0.lastName?.lowercased().hasPrefix(string) ?? false
        }
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension FriendsListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArrowContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memberCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bubbleMemberCell, for: indexPath)
        
        let contact = filteredArrowContacts[indexPath.row]
        memberCell?.setupCell(person: contact)
        
        return memberCell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension FriendsListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Show Arrow friend's profile.
    }
    
}

// MARK: - Event Handlers

extension FriendsListVC {
    
    @IBAction func addFriendsButtonPressed(_ sender: AnyObject) {
        // TODO: Show add friends flow (unclear).
    }
    
    @objc func searchTextFieldChanged(_ textField: UITextField) {
        guard let searchString = textField.text else {
            return
        }
        
        filterContacts(string: searchString)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension FriendsListVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
