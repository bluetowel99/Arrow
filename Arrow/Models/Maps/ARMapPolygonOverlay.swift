
import GoogleMaps

struct ARMapPolygonOverlay {
    static let mapOverlayBaseZLevel: Int32 = 10
    static let mapOverlayGlassZLevel: Int32 = 11
    
    let encodedPaths: String
    let basePolygon: GMSPolygon
    let glassPolygon: GMSPolygon
    
    var perspective: ARMapPerspective = .twoD {
        didSet {
            switch perspective {
            case .threeD:
                if glassPolygon.map == nil {
                    glassPolygon.map = map
                }
            case .twoD:
                glassPolygon.map = nil
            }
        }
    }
    
    private let map: GMSMapView
    
    init?(with encodedPaths: String, color: UIColor, map: GMSMapView) {
        
        guard let path = GMSPath(fromEncodedPath: encodedPaths) else { return nil }
        self.encodedPaths = encodedPaths
        self.map = map
        
        self.basePolygon = GMSPolygon()
        basePolygon.path = path
        basePolygon.fillColor = color.withAlphaComponent(0.5)
        basePolygon.strokeColor = color
        basePolygon.strokeWidth = 1
        basePolygon.zIndex = ARMapPolygonOverlay.mapOverlayBaseZLevel
        
        self.glassPolygon = GMSPolygon()
        let offsetPath = path.pathOffset(byLatitude: 0.00002, longitude: 0)
        glassPolygon.path = offsetPath
        glassPolygon.fillColor = UIColor.white.withAlphaComponent(0.5)
        glassPolygon.strokeColor = UIColor.white.withAlphaComponent(0.5)
        glassPolygon.strokeWidth = 0
        glassPolygon.zIndex = ARMapPolygonOverlay.mapOverlayGlassZLevel
    }
    
    func add() {
        basePolygon.map = map
        if perspective == .threeD {
            glassPolygon.map = map
        }
    }
    
    func remove() {
        basePolygon.map = nil
        glassPolygon.map = nil
    }
}

extension ARMapPolygonOverlay: Equatable {}
func == (lhs: ARMapPolygonOverlay, rhs: ARMapPolygonOverlay) -> Bool {
    return lhs.encodedPaths == rhs.encodedPaths
}

extension ARMapPolygonOverlay: Hashable {
    var hashValue: Int {
        return encodedPaths.hashValue
    }
}
