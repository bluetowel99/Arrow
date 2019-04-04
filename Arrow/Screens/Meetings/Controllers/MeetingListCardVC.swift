
import UIKit

protocol MeetingListCardDelegate {
    func MeetingListWillClose()
    func MeetingListWillCreateNewMeeting()
    func MeetingListDidSelect(meeting: ARMeeting)
}
final class MeetingListCardVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.meetingListCard()
    static var kStoryboardIdentifier: String? = "MeetingListCardVC"

    @IBOutlet weak var blurredBackgroundView: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var tableView: UITableView!

    var delegate: MeetingListCardDelegate?

    var meetings: [ARMeeting]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createAction(_ sender: Any) {
        self.delegate?.MeetingListWillCreateNewMeeting()
    }
    @IBAction func closeAction(_ sender: Any) {
        self.delegate?.MeetingListWillClose()
    }

}

// MARK: - UI Helpers

extension MeetingListCardVC {

    func setupView() {
        if let activeBubble = ARPlatform.shared.userSession?.bubbleStore.activeBubble {
            meetings = activeBubble.meetings
        }
        else
        {
            return
        }
        
        self.tableView.allowsSelection = true
        self.setupBackgroundBlur()
        self.cardContainer.layer.cornerRadius = 8.0
        self.view.backgroundColor = UIColor.clear
        //swift 3
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

    fileprivate func setupBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredBackgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredBackgroundView.addSubview(blurEffectView)
        blurredBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction(_:))))
    }
}

extension MeetingListCardVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let meetings = self.meetings {
            return meetings.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.meetingListTableViewCell)
        if(cell == nil) {
            cell = MeetingListTableViewCell()
        }
        let meeting = meetings?[indexPath.row]
        cell?.setup(meeting: meeting!)
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meeting =  meetings?[indexPath.row]
        self.delegate?.MeetingListDidSelect(meeting: meeting!)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }

}
