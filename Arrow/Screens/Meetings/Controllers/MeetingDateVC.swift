
import UIKit
import SVProgressHUD

final class MeetingDateVC: ARViewController , StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.meetingDate()
    static var kStoryboardIdentifier: String? = "MeetingDateVC"


    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    var meeting: ARMeeting?
    var place: ARGooglePlace?

    var delegate: CreateMeetingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = self.meeting?.title
        setupView()
    }

}

// MARK: - UI Helpers

extension MeetingDateVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton
        
        self.placeNameLabel.text = place?.name
        self.placeAddressLabel.text = place?.address

        self.datePicker.minimumDate = Date()
        self.datePicker.date = Date()
    }

}

// MARK: - Event Handlers

extension MeetingDateVC {

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createMeetingDidCancel(controller: self)
    }
    @IBAction func actionButtonPressed(_ sender: Any) {
        let meetingSummmaryVC = MeetingSummaryVC.instantiate()
        let currentDate = Date().addingTimeInterval(4.0 * 60.0)
        guard self.datePicker.date >= currentDate else {
            SVProgressHUD.showError(withStatus: "Meet time must be set at least 5 minutes in the future!")
            return
        }
        self.meeting?.date = self.datePicker.date
        meetingSummmaryVC.place = self.place
        meetingSummmaryVC.meeting = self.meeting
        meetingSummmaryVC.delegate = self.delegate
        navigationController?.pushViewController(meetingSummmaryVC, animated: true)
    }
}
