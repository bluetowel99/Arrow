
import Foundation
import GoogleMaps

class ClusterMarker: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!

    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
