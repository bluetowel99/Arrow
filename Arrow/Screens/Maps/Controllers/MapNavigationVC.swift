
import UIKit

final class MapNavigationVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.mapNavigation()
    static var kStoryboardIdentifier: String? = "MapNavigationVC"

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startPointField: UITextField!
    @IBOutlet weak var endPointField: UITextField!
    @IBOutlet weak var destinationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    var place: ARGooglePlace?

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        if let place = self.place {
            mapView.animate(toLocation: CLLocationCoordinate2DMake(place.latitude, place.longitude))
            mapView.animate(toZoom: 15)
            let marker = GMSMarker(position: CLLocationCoordinate2DMake(place.latitude, place.longitude))
            marker.icon = R.image.pOINavMapMarker()
            marker.map = mapView
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UI Helpers

extension MapNavigationVC {

    fileprivate func setupView() {
        endPointField.text = place?.name
        destinationLabel.text = place?.name
    }

}
