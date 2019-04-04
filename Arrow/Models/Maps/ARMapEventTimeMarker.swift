
import Foundation

import GoogleMaps

struct ARMapEventTimeMarker {
    private let map: GMSMapView
    private let threeDMarker: GMSMarker!
    private let twoDMarker: GMSMarker!
    var location: CLLocationCoordinate2D!
    
    var perspective: ARMapPerspective = .twoD {
        didSet {
         addMarkerMaps()
        }
    }
    
    init?(map: GMSMapView, meeting: ARMeeting) {
        self.map = map
        
        let markerView2D = MapsFlagMarkerView.instanceFor2DFromNib()
        location = CLLocationCoordinate2D(latitude: meeting.latitude!, longitude: meeting.longitude!)
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "h:mma"
        if(meeting.date == nil) {
            markerView2D.timeLabel.text = "ERROR"
        } else {
            markerView2D.timeLabel.text = dateFormatterGet.string(from: meeting.date!)
        }
        

        twoDMarker = GMSMarker()
        twoDMarker.iconView = markerView2D
        twoDMarker.tracksViewChanges = true
        twoDMarker.position = location
        twoDMarker.zIndex = 20
        twoDMarker.userData = meeting;
        
        let markerView3D = MapsFlagMarkerView.instanceFor3DFromNib()
        threeDMarker = GMSMarker()
        threeDMarker.iconView = markerView3D
        threeDMarker.tracksViewChanges = true
        //threeDMarker.iconView?.contentMode = .center
        threeDMarker.position = location
        threeDMarker.zIndex = 20
        threeDMarker.userData = meeting
    }

    func add() {
        addMarkerMaps()
    }
    
    func remove() {
        threeDMarker.map = nil
        twoDMarker.map = nil
    }
    
    func update(date: Date?) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "h:mma"
        if let checkedDate = date,
            let newMarker = twoDMarker.iconView as? MapsFlagMarkerView {
            newMarker.timeLabel.text?.append("\n\(dateFormatterGet.string(from: checkedDate))")
            twoDMarker.iconView = newMarker
        }
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

extension ARMapEventTimeMarker: Equatable {
    static func ==(lhs: ARMapEventTimeMarker, rhs: ARMapEventTimeMarker) -> Bool {
        return (lhs.location.latitude == rhs.location.latitude && lhs.location.longitude == rhs.location.longitude)
    }
}
