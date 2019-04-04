
import UIKit

final class PhonePickerPopoverVC: UIViewController, NibViewController {
    
    static var kNib: UINib = R.nib.phonePickerPopover()
    
    fileprivate let kMaxTableViewHeightRatio: CGFloat = 0.85
    
    @IBOutlet weak var backgroundDismissButton: UIButton!
    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate(set) var contactInfo: ARContactStore.LocalContactInfo! {
        didSet {
            tableView.reloadData()
            promptView.layoutIfNeeded()
            updateTableViewHeight()
        }
    }
    var delegate: PhonePickerPopoverDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setLocalizableString()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePromptViewShadow()
    }
    
    func setupPicker(for contactInfo: ARContactStore.LocalContactInfo) {
        self.contactInfo = contactInfo
    }
    
}

// MARK: - UI Helpers

extension PhonePickerPopoverVC {
    
    fileprivate func setupView() {
        promptView.layer.cornerRadius = 5.0
        promptView.layer.shadowColor = R.color.arrowColors.hathiGray().cgColor
        promptView.layer.shadowOpacity = 0.5
        promptView.layer.shadowRadius = 2.0
        promptView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        
        tableView.separatorStyle = .none
        tableView.register(R.nib.phonePickerCell)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = PhonePickerCell.estimatedRowHeight
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    fileprivate func setLocalizableString() { }
    
    fileprivate func updatePromptViewShadow() {
        promptView.layer.shadowPath = UIBezierPath(rect: promptView.bounds).cgPath
    }
    
    fileprivate func updateTableViewHeight() {
        var tableViewHeight = tableView.contentSize.height
        let maxTableHeight = view.frame.height * kMaxTableViewHeightRatio
        if tableViewHeight > maxTableHeight {
            tableViewHeight = maxTableHeight
        }
        tableViewHeightConstraint.constant = tableViewHeight
        updatePromptViewShadow()
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension PhonePickerPopoverVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactInfo.phoneNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.phonePickerCell, for: indexPath)
        let phoneInfo = contactInfo.phoneNumbers[indexPath.item]
        cell?.setupCell(phoneLabel: phoneInfo.label, phoneNumber: phoneInfo.number)
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension PhonePickerPopoverVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactInfo.person.phone = contactInfo.phoneNumbers[indexPath.item].number
        delegate?.phonePickerPopoverDidSelect(controller: self, selection: contactInfo)
    }
    
}

// MARK:- Event Handlers

extension PhonePickerPopoverVC {
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        delegate?.phonePickerPopoverDidDismiss(controller: self)
    }
    
}

// MARK: - PhonePickerPopoverDelegate Definition

protocol PhonePickerPopoverDelegate {
    func phonePickerPopoverDidDismiss(controller: PhonePickerPopoverVC)
    func phonePickerPopoverDidSelect(controller: PhonePickerPopoverVC, selection: ARContactStore.LocalContactInfo)
}
