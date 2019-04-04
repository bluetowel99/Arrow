
import Foundation

final class MessagingNewGroupVC: ARViewController, StoryboardViewController, UITextFieldDelegate {
    static var kStoryboard: UIStoryboard = R.storyboard.messagingNewGroup()
    static var kStoryboardIdentifier: String? = "MessagingNewGroupVC"

    //var MessageThread: MessageThread?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contactTableView: UITableView!

    @IBOutlet weak var leaveButton: UIButton!

    @IBOutlet weak var notificationButton: UIButton!

    fileprivate var selectedContacts = Dictionary<String, ARPerson>()

    @IBOutlet weak var nameContainer: UIView!
    fileprivate var contactArray = [ARPerson]()

    fileprivate var notificationAllow = false
    fileprivate var nextBarButton = UIBarButtonItem()
    @IBAction func toogleNotificationAction(_ sender: Any) {
        if notificationAllow {
            notificationButton.setImage(R.image.emptyOval(), for: .normal)
            notificationAllow = false
        } else {
            notificationButton.setImage(R.image.contactSelected(), for: .normal)
            notificationAllow = true
        }
    }

    @IBAction func leaveAction(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarTitle = "Chat Details"
        self.leaveButton.isHidden = true
        nameContainer.layer.cornerRadius = 8.0

        let nextBarButton = UIBarButtonItem(title: "DONE", style: .plain, target: self, action: #selector(nextButtonPressed(_:)))
        nextBarButton.setTitleTextColor(R.color.arrowColors.hathiGray(), for: .disabled)
        nextBarButton.setTitleTextColor(R.color.arrowColors.waterBlue(), for: .normal)
        nextBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextBarButton
        self.nextBarButton = nextBarButton

        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    @IBAction func addContactAction(_ sender: Any) {
        let addmembers = MessagingAddContacts.instantiate()
        addmembers.delegate = self
        self.navigationController?.pushViewController(addmembers, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension  MessagingNewGroupVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagingAddContactTTableViewCell, for: indexPath)
        let user = self.contactArray[indexPath.row]
        cell?.setUser(user: user)
        cell?.row = indexPath.row
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
}

extension  MessagingNewGroupVC:UITableViewDelegate {

}

// MARK: - Event Handlers

extension MessagingNewGroupVC {

    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        self.nextBarButton .isEnabled = false
        postThread { (tread, error) in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            }
            self.nextBarButton .isEnabled = true
        }
    }
    
}

extension MessagingNewGroupVC: AddBContactsMembersDelegate {
    func addContactsDidComplete(controller: MessagingAddContacts, users: Dictionary<String, ARPerson>) {
        for (key, user) in users {
            self.selectedContacts[key] = user
        }
        self.contactArray = Array(self.selectedContacts.values)
        self.contactTableView.reloadData()
    }
}

extension MessagingNewGroupVC {
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            self.nextBarButton.isEnabled = true
        } else {
            self.nextBarButton.isEnabled = false
        }
    }
}

extension MessagingNewGroupVC: MessagingAddContactTTableViewCellDelegate {
    func didTapDelete(row: Int) {
            let person = self.contactArray[row]
        if let identifier = person.identifier {
            self.selectedContacts[identifier] = nil
            self.contactArray = Array(self.selectedContacts.values)
            self.contactTableView.reloadData()
        }
    }
    func didTapCall(row: Int) {

    }
    func didTapArrow(row: Int) {

    }
}

extension MessagingNewGroupVC {
    fileprivate func postThread(callback: ((ARMessageThread?, NSError?) -> Void)?) {
        var numbers = ""
        for person in self.contactArray {
            if let phoneNumber = person.phone?.cleanPhoneFormat() {
                if numbers == "" {
                    numbers += phoneNumber
                } else {
                    numbers += ","
                    numbers += phoneNumber
                }
            }
        }
        let getAllThreadsReq = CreateThreadRequest(platform: ARPlatform.shared, title: nameTextField.text!, numbers: numbers)
        let _ = networkSession?.send(getAllThreadsReq) { result in
            switch result {
            case .success(let threads):
                callback?(threads, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
}
