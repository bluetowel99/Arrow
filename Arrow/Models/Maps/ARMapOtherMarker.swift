
import CoreLocation

import GoogleMaps

struct ARMapOtherMarker {
    private let map: GMSMapView
    private let threeDMarker: GMSMarker!
    private let twoDMarker: GMSMarker!
    fileprivate let place: ARGooglePlace
    
    var perspective: ARMapPerspective = .twoD { didSet { addMarkerMaps() } }

    init?(with poi: ARGooglePlace, mapView: GMSMapView) {
        map = mapView
        place = poi
        let markerView = ARMapOther3DMarkerView.instanceFromNib()
        //markerView.iconView.image = ARMapOtherMarker.threeDMarkerImage(for: poi)
        //markerView.shadowImageView.image = ARMapOtherMarker.threeDShadowImage(for: poi)
        
        threeDMarker = GMSMarker()
        threeDMarker.iconView = markerView
        threeDMarker.iconView?.contentMode = .center
        threeDMarker.position = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
        threeDMarker.zIndex = 20
        threeDMarker.userData = poi
        
        twoDMarker = GMSMarker()
        twoDMarker.iconView = UIImageView(image: ARMapOtherMarker.twoDMarkerImage(for: poi))
        twoDMarker.iconView?.contentMode = .center
        twoDMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        twoDMarker.position = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
        twoDMarker.userData = poi
        
    }
    
    func add() {
        addMarkerMaps()
    }
    
    func remove() {
        threeDMarker.map = nil
        twoDMarker.map = nil
    }
    
    fileprivate func addMarkerMaps() {
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

private extension ARMapOtherMarker {
    
    static func threeDMarkerImage(for poi: ARGooglePlace) -> UIImage? {
        guard let mainType = poi.types?.first else {
            return nil
        }
        
        switch mainType {
        case .bar:
            return R.image.mapMarkerBar3D()
        case .gym:
            return R.image.mapMarkerGym3D()
        case .movieTheater:
            return R.image.mapMarkerMovies3D()
        case .outdoorRecreation:
            return R.image.mapMarkerOutdoorRec3D()
        case .restaurant:
            return R.image.mapMarkerRestaurant3D()
        }
    }
    
    static func threeDShadowImage(for poi: ARGooglePlace) -> UIImage? {
        return R.image.mapMarkerRestaurantShadow3D()
    }
    
    static func twoDMarkerImage(for poi: ARGooglePlace) -> UIImage? {
        guard let mainType = poi.types?.first else {
            return nil
        }
        
        switch mainType {
        case .bar:
            return R.image.barMapMarker()
        case .gym:
            return R.image.gymMapMarker()
        case .movieTheater:
            return R.image.moviesMapMarker()
        case .outdoorRecreation:
            return R.image.outdoorRecMapMarker()
        case .restaurant:
            return R.image.restaurantMapMarker()
        }
    }
}

extension ARMapOtherMarker: Equatable {}

func == (lhs: ARMapOtherMarker, rhs: ARMapOtherMarker) -> Bool {
    return ((lhs.place.latitude == rhs.place.latitude) &&
        (lhs.place.longitude == rhs.place.longitude))
}

extension ARMapOtherMarker: Hashable {
    var hashValue: Int {
        return place.latitude.hashValue ^ place.longitude.hashValue
    }
}
