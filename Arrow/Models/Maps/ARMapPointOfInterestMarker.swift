
import Foundation
import GoogleMaps

struct ARMapPointOfInterestMarker {
    let pointOfInterest: PointOfInterest
    private let map: GMSMapView
    private let threeDMarker: GMSMarker!
    private let twoDMarker: GMSMarker!
    
    var perspective: ARMapPerspective = .twoD {
        didSet {
         addMarkerMaps()
        }
    }
    
    init?(with poi: PointOfInterest, map: GMSMapView) {
        self.pointOfInterest = poi
        self.map = map
        
        let markerView = ARMapPointOfInterest3DMarkerView.instanceFromNib(with: poi)
        let poiMarkerLocation = CLLocationCoordinate2D(latitude: poi.position.latitude, longitude: poi.position.longitude)
        
        threeDMarker = GMSMarker()
        threeDMarker.iconView = markerView
        threeDMarker.iconView?.contentMode = .center
        threeDMarker.position = poiMarkerLocation
        threeDMarker.zIndex = 20
        threeDMarker.userData = poi
        
        twoDMarker = GMSMarker()
        twoDMarker.icon = R.image.mapMarkerMovies2D()
        twoDMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        twoDMarker.position = poiMarkerLocation
        twoDMarker.userData = poi
    }

    func add() {
        addMarkerMaps()
    }
    
    func remove() {
        threeDMarker.map = nil
        twoDMarker.map = nil
    }
    
    func addMarkerMaps() {
        switch perspective {
        case .threeD:
            threeDMarker.map = map
            twoDMarker.map = nil
        case .twoD:
            threeDMarker.map = nil
            twoDMarker.map = map
        }
    }
}

extension ARMapPointOfInterestMarker: Equatable {}
func == (lhs: ARMapPointOfInterestMarker, rhs: ARMapPointOfInterestMarker) -> Bool {
    return ((lhs.pointOfInterest.position.latitude == rhs.pointOfInterest.position.latitude) &&
        (lhs.pointOfInterest.position.longitude == rhs.pointOfInterest.position.longitude))
}

extension ARMapPointOfInterestMarker: Hashable {
    var hashValue: Int {
        return pointOfInterest.position.latitude.hashValue ^ pointOfInterest.position.longitude.hashValue
    }
}
