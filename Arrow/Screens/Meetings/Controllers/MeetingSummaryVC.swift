
import UIKit

import GoogleMaps

final class MeetingSummaryVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.meetingSummary()
    static var kStoryboardIdentifier: String? = "MeetingSummaryVC"

    var meeting: ARMeeting?
    var place: ARGooglePlace?

    @IBOutlet weak var bubbleNameLabel: UILabel!
    @IBOutlet weak var meetingPlaceName: UILabel!
    @IBOutlet weak var meetingDescriptionLabel: UILabel!
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingAddressLabel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    fileprivate let defaultZoomLevel: Float = 16.0

    var delegate: CreateMeetingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = self.meeting?.title
        self.setupView()
        self.setupMapView()
    }
}


// MARK: - UI Helpers

extension MeetingSummaryVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton

        if let place = self.place, let meeting = self.meeting, let date = meeting.date {
            self.bubbleNameLabel.text = ARPlatform.shared.userSession?.bubbleStore.activeBubble?.title
            self.meetingPlaceName.text = place.name
            self.meetingDescriptionLabel.text = meeting.description
            self.meetingDateLabel.text = humanReadableDateTimeFormatter.string(from: date)
            self.meetingAddressLabel.text = place.address
        }

    }

}

// MARK: - Map Setup

extension MeetingSummaryVC {
    
    fileprivate func setupMapView() {
        guard let place = self.place else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: place.latitude, longitude: place.longitude, zoom: defaultZoomLevel)
        mapView.camera = camera
        mapView.settings.scrollGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.isBuildingsEnabled = false
        
        let marker = GMSMarker(position: CLLocationCoordinate2DMake(place.latitude, place.longitude))
        marker.icon = R.image.mapsFlag3D()
        marker.isFlat = true
        marker.map = mapView
    }
    
    
}

// MARK: - Event Handlers

extension MeetingSummaryVC {

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createMeetingDidCancel(controller: self)
    }

    @IBAction func actionButtonPressed(_ sender: Any) {
        if let meeting = self.meeting {
            self.createMeeting(meeting: meeting, callback: { (meeting, error) in
                if let error = error {
                    print("Error creating meeting \(error)")
                    return
                }
                self.delegate?.createMeetingDidComplete(controller: self, meeting: meeting!)
            })
        }
    }
}

// MARK: - Networking

extension MeetingSummaryVC {

    fileprivate func createMeeting(meeting: ARMeeting, callback: ((ARMeeting?, Error?) -> Void)?) {
        
        if let activeBubble = ARPlatform.shared.userSession?.bubbleStore.activeBubble {
            
            let createMeetingReq = CreateMeetingRequest(platform: platform, meeting: meeting, bubble: activeBubble.identifier!)
            let _ = networkSession?.send(createMeetingReq) { result in
                switch result {
                case .success(let meeting):
                    callback?(meeting, nil)
                case .failure(let error):
                    callback?(nil, error)
                }
            }
            
        } else {
            print("activeBubble not set in MeetingSummaryVC createMeeting")
        }
    }
}
