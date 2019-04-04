
import UIKit

import GoogleMaps
final class MeetingLocationConfirmVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.meetingLocationConfirm()
    static var kStoryboardIdentifier: String? = "MeetingLocationConfirmVC"

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    fileprivate let defaultZoomLevel: Float = 16.0

    var meeting: ARMeeting?
    var place: ARGooglePlace?

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

extension MeetingLocationConfirmVC {

    fileprivate func setupView() {
        // Navigation bar buttons.
        let cancelBarButton = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(cancelButtonPressed(_:)))
        navigationItem.rightBarButtonItem = cancelBarButton

    }
}

// MARK: - Map Setup

extension MeetingLocationConfirmVC {

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

        self.placeNameLabel.text = place.name
        self.placeAddressLabel.text = place.address

    }


}

// MARK: - Event Handlers

extension MeetingLocationConfirmVC {

    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.createMeetingDidCancel(controller: self)
    }

    @IBAction func removePlaceButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func actionButtonPressed(_ sender: Any) {
        let meetingDateVC = MeetingDateVC.instantiate()
        meetingDateVC.place = self.place
        meetingDateVC.meeting = self.meeting
        meetingDateVC.delegate = self.delegate
        navigationController?.pushViewController(meetingDateVC, animated: true)
    }
}
