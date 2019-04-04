
import UIKit

enum MessagingInboxState {
    case empty
    case populated
}

final class MessagingInboxVC: UITableViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.messaging()
    static var kStoryboardIdentifier: String? = "MessagingInboxVC"

    fileprivate var viewModel = ARMessagingInbox()

    @IBOutlet weak var filterTextField: UITextField!

    var lastMessageDict = Dictionary<String,ARMessage>()

    var threadIds: [String] = []

    @IBOutlet var headerView: UIView!

    var threadStore: ARMessageThreadStore?

    fileprivate var inboxState: MessagingInboxState = .empty {
        didSet {
            updateUI()
        }
    }
    var useNavigationBarItem: Bool = true
    override var navigationItem: UINavigationItem {
        get {
            return useNavigationBarItem ? (navigationController?.navigationBar.items?.first)! : super.navigationItem
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        self.threadStore = ARPlatform.shared.userSession?.threadStore
        self.threadStore?.messagingInboxVC = self
        self.fetchThreadList()
        filterTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchThreadList(forceReload: true)
        let createGroupBarButton = UIBarButtonItem(image: R.image.createGroupIcon(), style: .plain, target: self, action: #selector(createGroupButtonPressed(_:)))
        navigationItem.rightBarButtonItem  = createGroupBarButton
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageThread = viewModel.messageThreads[indexPath.row]
        let messagesTableVC = MessagesTableVC.instantiate()
        messagesTableVC.thread = messageThread
        messagesTableVC.threadId = String(describing: messageThread.identifier)
        navigationController?.pushViewController(messagesTableVC, animated: true)
    }

    func fetchThreadList(forceReload: Bool = false) {
        threadStore?.fetchUserThreads(forceRefresh: forceReload) { threads in
            guard let threads = threads else {
                return
            }
            self.viewModel.messageThreads = threads
            self.tableView.reloadData()
        }
    }
}

// MARK: - UI Helpers

extension MessagingInboxVC {

    func setupView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 97
        updateUI()
    }

    func updateUI() {
        guard let table = tableView else { return }

        switch inboxState {
        case .empty:
            table.tableHeaderView = nil
            table.contentInset = UIEdgeInsetsMake(0, 0, tabBarHeight(), 0)
            table.isScrollEnabled = false
        case .populated:
            table.tableHeaderView = headerView
            table.contentInset = UIEdgeInsetsMake(-10, 0, tabBarHeight(), 0)
            table.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, tabBarHeight(), 0)
            table.isScrollEnabled = true
        }
    }

    fileprivate func tabBarHeight() -> CGFloat {
        if let tabBarHeight = tabBarController?.tabBar.frame.size.height {
            return tabBarHeight
        }

        return 0
    }
}

// MARK: - UITableView Datasource

extension MessagingInboxVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch inboxState {
        case .empty:
            return tableView.bounds.height - tabBarHeight()
        case .populated:
            if let filterText = self.filterTextField.text, self.viewModel.messageThreads.count > indexPath.row, !filterText.isEmpty {
                let thread = self.viewModel.messageThreads[indexPath.row]
                if let title = thread.title?.lowercased(), !title.contains(filterText.lowercased()) {
                    return 0
                }
            }
            return 97
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch inboxState {
        case .empty:
            return 1
        case .populated:
            return self.viewModel.messageThreads.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch inboxState {
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyPlaceholder") as! MessagingEmptyInboxTableViewCell
            cell.heightConstraint.constant = tableView.bounds.height - tabBarHeight()
            return cell
        case .populated:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageInboxCell") as! MessagingInboxTableViewCell
            viewModel.configure(cell: cell, atRow: indexPath.row)

            return cell
        }
    }

    func reloadData() {
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
        }, completion: nil);
    }
}

// MARK: - Event Handlers

extension MessagingInboxVC {

    func tempTransitionToInbox() {
        switch inboxState {
        case .empty:
            inboxState = .populated
        case .populated:
            inboxState = .empty
        }

        reloadData()
    }

    @IBAction func createBubble(_ sender: Any) {
        tempTransitionToInbox()
    }

    @IBAction func newMessage(_ sender: Any) {
        tempTransitionToInbox()
    }

    @IBAction func createGroupButtonPressed(_ sender: AnyObject) {
        let createGroupVc = MessagingNewGroupVC.instantiate()
        self.navigationController?.pushViewController(createGroupVc, animated: true)
    }



}

extension MessagingInboxVC: UITextFieldDelegate {

    @objc func textFieldEditingChanged(_ textField: UITextField) {
        self.tableView.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}





