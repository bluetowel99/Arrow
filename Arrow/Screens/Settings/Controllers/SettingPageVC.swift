
import UIKit

// MARK: - Class SettingPageVC

final class SettingPageVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.settingPage()
    static var kStoryboardIdentifier: String? = "SettingPageVC"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var settingItems = [ARSettingOption]()
    
    var pageController: SettingPageController! {
        didSet {
            pageController.platform = platform
            pageController.networkSession = networkSession!
            pageController.refreshCallback = dataSourceDidRefresh(items:)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = pageController else {
            assertionFailure("Page Controller must be set.")
            return
        }
        
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        pageController.refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appWillEnterForeground(_ notification: Notification) {
        pageController.refresh()
    }
    
}

// MARK: - UI Helpers

extension SettingPageVC {
    
    fileprivate func setupView() {
        isNavigationBarBackTextHidden = true
        navigationBarTitle = pageController.navigationBarTitle
        titleLabel.text = pageController.menuTitle.uppercased()
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = SettingOptionCell.cellHeight
        tableView.register(R.nib.settingOptionCell)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func dataSourceDidRefresh(items: [ARSettingOption]) {
        settingItems = items
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension SettingPageVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingOptionCell)
        let option = settingItems[indexPath.row]
        let isLastRow = indexPath.row == settingItems.count - 1
        cell?.setupCell(option: option, isLastRow: isLastRow)
        
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension SettingPageVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pageController.settingPageDidSelect(controller: self, optionIndex: UInt(indexPath.row))
    }
    
}
