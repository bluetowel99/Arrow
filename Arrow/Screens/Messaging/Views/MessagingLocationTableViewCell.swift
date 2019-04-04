
import Foundation
import GoogleMaps
class MessagingLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var placeAddressLabel: UILabel!

    @IBOutlet weak var mapview: GMSMapView!
    fileprivate let defaultZoomLevel: Float = 16.0
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cardContainer.layer.cornerRadius = 8.0
        self.cardContainer.layer.shadowColor = UIColor(white: 0.67, alpha: 1.0).cgColor
        self.cardContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.cardContainer.layer.shadowOpacity = 0.5
        self.cardContainer.layer.shadowRadius = 4.0
        self.mapview.settings.tiltGestures = false
        self.mapview.settings.rotateGestures = false
        self.mapview.isBuildingsEnabled = false

    }

    fileprivate let currentLocationMarker: GMSMarker = {
        let marker = GMSMarker()
        marker.icon = R.image.locationSharePosition()
        marker.isFlat = true
        return marker
    }()

    func setLocation(lat:Float,lng:Float) {
        currentLocationMarker.map = mapview
        currentLocationMarker.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng))
        mapview.animate(toLocation: CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lng)))
        if mapview.camera.zoom < defaultZoomLevel {
            mapview.animate(toZoom: defaultZoomLevel)
        }
    }

}
