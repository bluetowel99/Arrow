
import UIKit
import SVProgressHUD

final class BubblesListVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.bubblesListVC()
    static var kStoryboardIdentifier: String? = "BubblesListVC"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateMessageLabel: UILabel!
    @IBOutlet weak var emptyStateButton: UIButton!
    
    fileprivate var searchTerm: String? = nil
    fileprivate var bubbles = [ARBubble]()
    
    var bubbleStore: ARBubbleStore?
    var delegate: BubblesListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupEmptyStateView()
        fetchBubblesList()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            
//            guard let bubblePerson = ARPlatform().userSession?.user else {
//                SVProgressHUD.showError(withStatus: "Must be logged in to delete bubble!")
//                return
//            }
//            let request = DeleteBubbleMembersRequest(platform: ARPlatform.shared, bubbleId: self.bubbles[indexPath.row].identifier!, toBeDeletedMembers: [bubblePerson])
            let request = DeleteBubbleRequest(platform: ARPlatform.shared, bubbleId: self.bubbles[indexPath.row].identifier!)
            let networkSession = ARNetworkSession.shared
            let _ = networkSession.send(request) { result in
                switch result {
                case .success(_):
                    self.fetchBubblesList(forceReload: true)
                    print("SUCCESS: token data sent to server - ready for push notifications")
                case .failure(let error):
                    print("ERROR: token data send error: \(error)")
                }
            }
        }
        return [delete]
    }
    
}

// MARK: - UI Helpers

extension BubblesListVC {
    
    func setupView() {
        navigationBarTitle = "Bubbles"
        isNavigationBarBackTextHidden = true
    }
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = SearchBarCell.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.register(R.nib.searchBarCell)
        tableView.register(R.nib.bubbleListCell)
        // Detect user taps on table view's background.
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped(_:))))
    }
    
    fileprivate func setupEmptyStateView() {
        emptyStateButton.layer.cornerRadius = 5
        emptyStateButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
        emptyStateButton.layer.borderWidth = 3.0
    }
    
    fileprivate func fetchBubblesList(forceReload: Bool = false) {
        bubbleStore?.fetchUserBubbles(forceRefresh: forceReload) { bubbles in
            guard let bubbles = bubbles else {
                return
            }
            
            self.bubbles = bubbles
            self.tableView.reloadData()
            self.delegate?.bubblesListDidReloadData(controller: self)
        }
    }
    
}

// MARK: - Public Methods

extension BubblesListVC {
    
    func reloadBubbleData() {
        fetchBubblesList(forceReload: true)
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension BubblesListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Show empty state, if needed.
        emptyStateView.isHidden = !bubbles.isEmpty
        
//        return bubbles.isEmpty ? 0 : 2
        return bubbles.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
//        case 0:
//            return 1
        case 0:
            return bubbles.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
//        case 0:
//            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchBarCell)
//            cell?.setup(icon: R.image.search(), placeholderText: "Search", searchText: searchTerm, inputAccessoryView: nil)
//            return cell ?? UITableViewCell()
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.bubbleListCell)
            let bubble = bubbles[indexPath.row]
            cell?.setup(bubble: bubble)
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension BubblesListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let bubble = bubbles[indexPath.row]
            delegate?.bubblesListDidSelect(controller: self, bubble: bubble)
        default:
            break
        }
    }
    
}

// MARK: - Event Handlers

extension BubblesListVC {
    
    @IBAction func createBubbleButtonPressed(sender: AnyObject) {
        delegate?.bubblesListCreateBubbleButtonPressed(controller: self)
    }
    
    @objc func backgroundViewTapped(_ sender: Any) {
        delegate?.bubblesListDismissedWithNoSelection(controller: self)
    }
    
}

// MARK: - BubblesListDelegate Definition

protocol BubblesListDelegate {
    func bubblesListDidReloadData(controller: BubblesListVC)
    func bubblesListDidSelect(controller: BubblesListVC, bubble: ARBubble)
    func bubblesListCreateBubbleButtonPressed(controller: BubblesListVC)
    func bubblesListDismissedWithNoSelection(controller: BubblesListVC)
}
