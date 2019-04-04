
import UIKit
import SVProgressHUD
import Localide

protocol MeetingRSVPViewDelegate {
    func MeetingRSVPDidSelect(meeting: ARMeeting)
}

class MeetingRSVPView: UIView {

    var view: UIView!

    @IBOutlet weak var twoButtonContainer: UIView!
    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var notGoingButton: UIButton!

    private var meeting: ARMeeting?
    private var invited: [ARPerson]!
    private var status: ARMeetingRVSPStatus?

    @IBOutlet weak var meetingTitleLabel: UILabel!
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingDescriptionLabel: UILabel!

    @IBOutlet weak var rsvpCollectionView: UICollectionView!
    let rsvpCellIdentifier = "rsvpCollectionCell"

    var platform: ARPlatform = ARPlatform.shared
    var networkSession: ARNetworkSession? = ARNetworkSession.shared

    var delegate: MeetingRSVPViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.goingButton.layer.cornerRadius = 5.0
        self.goingButton.layer.borderWidth = 3.0
        self.goingButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
        self.notGoingButton.layer.cornerRadius = 5.0
        self.notGoingButton.layer.borderWidth = 3.0
        self.notGoingButton.layer.borderColor = R.color.arrowColors.stormGray().cgColor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        view = instanceFromNib()

        // use bounds not frame or it'll be offset
        view.frame = bounds

        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)

        setupRSVPCollectionView()
    }

    func setupRSVPCollectionView() {
        self.rsvpCollectionView.register(UINib(nibName:"RSVPCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: rsvpCellIdentifier)
        self.rsvpCollectionView.delegate = self
        self.rsvpCollectionView.dataSource = self
    }

    func setMeeting(meeting: ARMeeting, status: ARMeetingRVSPStatus, members: [ARPerson]) {
        self.meeting = meeting
        self.status = status
        self.invited = members

        self.setupViews()
    }

    private func setupViews() {
        guard let meeting = self.meeting , let status = self.status else {
            return
        }

        switch status {
        case .going:
            self.twoButtonContainer.isHidden = true
            self.notGoingButton.isHidden = true
        case .notGoing:
            self.twoButtonContainer.isHidden = true
            self.goingButton.isHidden = true
        case .unanswered:
            self.goingButton.isHidden = false
            self.notGoingButton.isHidden = false
        }
        self.meetingTitleLabel.text = meeting.title
        self.meetingDescriptionLabel.text = meeting.description
        let meetingFormatted = meeting.dateString().replacingOccurrences(of: "day ", with: "day\r").replacingOccurrences(of: " at", with: "\r@")
        self.meetingDateLabel.text = meetingFormatted
    }

    func instanceFromNib() -> UIView {
        return UINib(nibName: "MeetingRSVPView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }

    @IBAction func goingButtonPressed(_ sender: Any) {
        rsvpHelper(going: true)
        notGoingButton.isHidden = true
    }

    @IBAction func notGoingButtonPressed(_ sender: Any) {
        rsvpHelper(going: false)
        goingButton.isHidden = true
    }

    @IBAction func rsvpButtonPressed(_ sender: Any) {
        self.delegate?.MeetingRSVPDidSelect(meeting: meeting!)
    }
    
    @IBAction func navButtonPressed(_ sender: Any) {
        if let latitude = meeting?.latitude, let longitude = meeting?.longitude {
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            Localide.sharedManager.promptForDirections(toLocation: location,  rememberPreference: true, onCompletion: nil)
        } else {
            SVProgressHUD.showError(withStatus: "Couldn't retrieve Meeting Location")
        }
    }
}

// Networking
extension MeetingRSVPView {

    func rsvpHelper(going: Bool) {
        guard let meeting = meeting else {
            SVProgressHUD.showError(withStatus: "No meeting set. Please reload meet spot")
            return
        }
        createRSVP(meeting: meeting, going: going) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Error responding to RSVP")
            } else {
                SVProgressHUD.showSuccess(withStatus: "Successfully Updated!")
                guard let user = self.platform.userSession?.user else { return }
                if !(self.meeting?.rsvps?.contains(user))! && going {
                    self.meeting?.rsvps?.append(user)
                } else if !going {
                    if let index = self.meeting?.rsvps?.index(of: user) {
                        self.meeting?.rsvps?.remove(at: index)
                    }
                }
                self.goingButton.isHidden = !going
                self.notGoingButton.isHidden = going
            }
        }
    }

    fileprivate func createRSVP(meeting: ARMeeting, going: Bool, callback:  ((Error?) -> Void)?) {
        let meetingRequest = CreateMeetingRSVPRequest(platform: platform, meeting: meeting, going: going)
        SVProgressHUD.show()
        let _ = networkSession?.send(meetingRequest) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
    }
}

// CollectionView
extension MeetingRSVPView: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return invited.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rsvpCellIdentifier, for: indexPath) as? RSVPCollectionViewCell

        let person = invited[indexPath.row]
        cell?.personImageView.isHidden = false
        if let personImage = person.thumbnail {
            cell?.personImageView.image = personImage
        } else if let personPictureUrl = person.pictureUrl {
            cell?.personImageView.setImage(from: personPictureUrl)
        } else {
            cell?.personImageView.isHidden = true
            cell?.initialsLabel.text = person.displayName(style: .abbreviated)
        }

        cell?.containerView.layer.cornerRadius = 24
        cell?.containerView.layer.masksToBounds = true

        return cell  ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.MeetingRSVPDidSelect(meeting: meeting!)
    }

}
