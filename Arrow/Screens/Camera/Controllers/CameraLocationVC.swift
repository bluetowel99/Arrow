
import AVFoundation
import UIKit

final class CameraLocationVC: ARKeyboardViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.cameraLocation()
    static var kStoryboardIdentifier: String? = "CameraLocationVC"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var currentLocationView: UIView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Public Properties
    
    var capturedMediaInfo: CapturedMediaInfo?
    
    // MARK: Private Properties
    
    fileprivate var nearbyLocations = [(title: String?, address: String?)]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: Delegate
    
    var delegate: DismissableControllerDelegate?
    
    // MARK: Overloaded Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Set Location"
        setupView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        isStatusBarHidden = false
    }
    
}

// MARK: - UI Helpers

extension CameraLocationVC {
    
    fileprivate func setupView() {
        // Navigation bar buttons.
        let skipBarButton = UIBarButtonItem(title: "SKIP", style: .plain, target: self, action: #selector(skipButtonPressed(_:)))
        navigationItem.rightBarButtonItem = skipBarButton
        
        // Search text field.
        searchTextField.clearButtonMode = .always
        searchTextField.keyboardType = .asciiCapable
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
    }
    
    fileprivate func setupTableView() {
        scrollView = tableView
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = NearbyLocationCell.cellHeight
        tableView.register(R.nib.nearbyLocationCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        nearbyLocations = [
            (title: "Basement Tavern", address: "2640 Main St., Santa Monica, CA"),
            (title: "Library Alehouse", address: "2911 Main St., Santa Monica, CA"),
            (title: "Father’s Office", address: "1018 Montana Ave., Santa Monica, CA"),
        ]
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension CameraLocationVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyLocations.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50, height: 30))
        headerLabel.backgroundColor = .white
        headerLabel.font = R.font.alegreyaSansMedium(size: 14.0)
        headerLabel.text = "NEARBY"
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.nearbyLocationCell)
        let location = nearbyLocations[indexPath.row]
        cell?.setupCell(title: location.title, address: location.address)
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension CameraLocationVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO(kia): Set the selected location as photo's location.
    }
    
}

// MARK: - Event Handlers

extension CameraLocationVC {
    
    @IBAction func skipButtonPressed(_ sender: AnyObject) {
        let cameraMembersVC = CameraMembersVC.instantiate()
        // TODO(kia): Add location info to captured media info.
        cameraMembersVC.capturedMediaInfo = capturedMediaInfo
        cameraMembersVC.delegate = delegate
        
        navigationController?.pushViewController(cameraMembersVC, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension CameraLocationVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
