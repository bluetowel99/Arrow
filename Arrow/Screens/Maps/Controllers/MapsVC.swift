
import GoogleMaps
import UIKit
import CoreLocation
import SVProgressHUD

enum ARMapPerspective {
    case threeD
    case twoD
}

final class MapsVC: ARViewController, StoryboardViewController {
    static var kStoryboard: UIStoryboard = R.storyboard.maps()
    static var kStoryboardIdentifier: String? = "MapsVC"
    
    let viewModel = ARMaps()
    
    fileprivate let defaultZoomLevel: Float = 16.0
    fileprivate let viewingAngle: Double = 40.0

    fileprivate var clusterManager: GMUClusterManager!
    
    @IBOutlet weak var mapsBubbleBar: MapsBubbleBar!
    @IBOutlet weak var mapControls: UIView!
    @IBOutlet weak var perspectiveButton: UIButton!
    @IBOutlet weak var createMeetingButton: UIButton!
    @IBOutlet weak var bubblesHoldingView: UIView!
    @IBOutlet weak var poiCardHoldingView: UIView!
    @IBOutlet weak var meetingListHoldingView: UIView!

    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 100
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        return manager
    }()

    fileprivate var mylocation: GMSMarker?

    fileprivate var lastlocationFetched: CLLocation?
    fileprivate var lastTimestamp: Date?

    fileprivate var mapsBubblesVC: MapsBubblesVC?
    fileprivate var poiCardVC: POICardVC?
    fileprivate var meetingListVC: MeetingListCardVC?
    fileprivate var mapView: GMSMapView!
    fileprivate var polygonOverlays = Set<ARMapPolygonOverlay>()
    fileprivate var pointOfInterestMarkers = Set<POIItem>()

    fileprivate var membersMarkerInfoVC: MapsMarkerInfoVC!
    
    var multiplier: CGFloat = 1
    
    fileprivate var perspective: ARMapPerspective = .twoD {
        didSet {
            animate(to: perspective)
        }
    }
    
    fileprivate var meetingMarkers: [ARMapEventTimeMarker]?
    fileprivate var peopleMarkers: [GMSMarker]?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        startUpdatingLocation()
        navigationBarTitleStyle = .compactLogo
        isNavigationBarBackTextHidden = true
        let createBubbleBarButton = UIBarButtonItem(image: R.image.addBubbleIcon(), style: .plain, target: self, action: #selector(createBubbleButtonPressed(_:)))
        navigationItem.rightBarButtonItems  = [createBubbleBarButton]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItem = nil
        stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        useNavigationBarItem = true
        setupMapView()
        setupMapBubbles()
        setupPOICard()
        setupMapStyling()
        setupMeetingList()
        self.mapView.delegate = self

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = ARClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                           renderer: renderer)
        renderer.delegate = self
        clusterManager.setDelegate(self, mapDelegate: self)
        
        meetingMarkers = [ARMapEventTimeMarker]()
        peopleMarkers = [GMSMarker]()

        self.mapView.isMyLocationEnabled = false
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.frame
    }

    private func randomScale() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
    }
    
}

extension MapsVC: GMUClusterManagerDelegate {

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                           zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return true
    }

}

extension MapsVC: GMUClusterRendererDelegate {


    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let info = marker.userData as? POIItem {
            if let types = info.place.types , types.count > 0{
                let type = types[0]
                switch type {
                case .bar:
                    if(info.place.litMeter != nil && info.place.litMeterEnabled != nil && info.place.litMeterEnabled == true) {
                        if(info.place.litMeter! > 0.5) {
                            marker.icon = R.image.barLit_high()
                        } else if(info.place.litMeter! > 0.0) {
                            marker.icon = R.image.barLit_mid()
                        } else if(info.place.litMeter! > -0.5) {
                            marker.icon = R.image.barLit_normal()
                        } else {
                            marker.icon = R.image.barLit_low()
                        }
                    } else {
                        marker.icon = R.image.barMapMarker()
                    }
                    break
                case .gym:
                    marker.icon = R.image.gymMapMarker()
                    break
                case .movieTheater:
                    marker.icon = R.image.moviesMapMarker()
                    break
                case .outdoorRecreation:
                    marker.icon = R.image.outdoorRecMapMarker()
                    break
                case .restaurant:
                    marker.icon = R.image.restaurantMapMarker()
                    break
                }
            }
        }
    }
}

class ARClusterRenderer : GMUDefaultClusterRenderer {

    override func shouldRender(as cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        if zoom > 17 {
            return false
        }
        return cluster.count > 4
    }
}


class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var place: ARGooglePlace!

    init(position: CLLocationCoordinate2D, name: String, place: ARGooglePlace) {
        self.position = position
        self.name = name
        self.place = place
    }
}
// MARK: - UI Helpers

extension MapsVC {
    func add(poi: ARGooglePlace) {
        //avoid duplicates
        ARPOIStore.mapsVC = self // this is stupid, but I'm being lazy
        if (!self.viewModel.poiStore.poiSet.contains(poi.placeId)) {
            self.viewModel.poiStore.poiSet.insert(poi.placeId)
            let position = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
            let item = POIItem(position: position, name: "saf", place: poi)
            pointOfInterestMarkers.insert(item)
            clusterManager.add(item)
            clusterManager.cluster()
        }
    }
    
    func add(person: ARPerson) {
        // if we don't have a location, don't put them on the map
        if(person.currentPosition == nil) {
            return
        }
        let markerView = MapsMemberMarkerView.instanceFromNib()
        markerView.person = person
        let marker = GMSMarker()
        marker.iconView = markerView
        marker.iconView?.contentMode = .center
        marker.position = person.currentPosition!
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.zIndex = 20
        marker.map = mapView
        marker.userData = person
        peopleMarkers!.append(marker)
    }
    
    fileprivate func setupMapView() {
        // TODO(jacob): The initial coordinates and zoom level will be replaced by a GMSCameraUpdate.fit(coordinateBounds, ...) to contain all the markers
        let camera = GMSCameraPosition.camera(withLatitude: 33.65026, longitude: -117.74344, zoom: defaultZoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.isBuildingsEnabled = false
        
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        
        if let tabBarHeight = tabBarController?.tabBar.frame.size.height {
            var mapInsets = mapView.padding
            mapInsets.bottom = tabBarHeight
            mapView.padding = mapInsets
        }
    }
    
    fileprivate func setupMapStyling() {
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    fileprivate func setupMapBubbles() {
        self.mapsBubbleBar.delegate = self
        
        let mapsBubblesVC = MapsBubblesVC.instantiate()
        self.mapsBubblesVC = mapsBubblesVC
        mapsBubblesVC.bubbleStore = platform.userSession?.bubbleStore
        mapsBubblesVC.listDelegate = self
        self.addChildViewController(childController: mapsBubblesVC, on: bubblesHoldingView)
        view.bringSubview(toFront: bubblesHoldingView)
        showBubblesList(show: false, animated: false)
    }
    
    fileprivate func setupPOICard() {
        
        let poiCardVC = POICardVC.instantiate()
        poiCardVC.delegate = self
        self.poiCardVC = poiCardVC
        self.addChildViewController(childController: poiCardVC, on: poiCardHoldingView)
        view.bringSubview(toFront: poiCardHoldingView)
        showPOICard(show: false)
    }
    
    fileprivate func setupMeetingList() {
        
        let meetingListCardVC = MeetingListCardVC.instantiate()
        meetingListCardVC.delegate = self
        self.meetingListVC = meetingListCardVC
        self.meetingListVC?.setupView()
        self.addChildViewController(childController: meetingListCardVC, on: meetingListHoldingView)
        view.bringSubview(toFront: meetingListHoldingView)
        showMeetingList(show: false)
    }
    
    fileprivate func showBubblesList(show: Bool, animated: Bool) {
        mapsBubbleBar.turnArrow(up: show, animated: animated)
        bubblesHoldingView.endEditing(true)
        bubblesHoldingView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0.0, animations: {
            self.bubblesHoldingView.layer.opacity = show ? 1.0 : 0.0
        }, completion: { _ in
            self.bubblesHoldingView.isHidden = !show
        })
        
        // Show/hide bubbles list.
        mapsBubblesVC?.hideBubblesList(!show, animated: animated)
    }
    
    fileprivate func toggleBubblesList(animated: Bool) {
        showBubblesList(show: bubblesHoldingView.isHidden, animated: animated)
    }
    
    fileprivate func showPOICard(show: Bool) {
        poiCardHoldingView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.poiCardHoldingView.layer.opacity = show ? 1.0 : 0.0
        }, completion: { _ in
            self.poiCardHoldingView.isHidden = !show
        })
    }
    
    fileprivate func navigateToPOIDetails(pointOfInterest poi: ARGooglePlace) {
        let poiDetailsVC = POIDetailsVC.instantiate()
        poiDetailsVC.setup(pointOfInterest: poi, loadFromServer: false)
        navigationController?.pushViewController(poiDetailsVC, animated: true)
    }
    
    fileprivate func showMeetingList(show: Bool) {
        self.meetingListVC?.setupView()
        meetingListHoldingView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.meetingListHoldingView.layer.opacity = show ? 1.0 : 0.0
        }, completion: { _ in
            self.meetingListHoldingView.isHidden = !show
        })
    }
    
    fileprivate func showMeetingIcons(show: Bool, bubble: ARBubble) {
        
        for marker in meetingMarkers!
        {
            marker.remove()
        }
        meetingMarkers!.removeAll()
        
        let currentMeetings = bubble.meetings?.filter({ (meeting) -> Bool in
            if let diff = Calendar.current.dateComponents([.hour], from: meeting.date!, to: Date()).hour, diff > 24 {
                return false
            } else {
                return true
            }
        })
        for meet in currentMeetings!
        {
            let metm = ARMapEventTimeMarker(map: mapView, meeting: meet)
            if let row = meetingMarkers?.index(of: metm!) {
                meetingMarkers![row].update(date: meet.date)
            } else {
                metm?.add()
                meetingMarkers!.append(metm!)
            }
        }
    }
    
    fileprivate func showMemberIcons(show: Bool, people: [ARPerson]) {
        
        for marker in peopleMarkers!
        {
            marker.map = nil
        }
        peopleMarkers!.removeAll()
        
        for person in people
        {
            if(person.filteredPhone() != ARPlatform.shared.userSession?.user?.filteredPhone()) {
                add(person: person)
            }
        }
    }
    
    fileprivate func addTempOverlays(location: CLLocation) {
        self.viewModel.getPOI(location: location) { places in
            let _ = places?.map { self.add(poi: $0) }
        }
        
        // let _ = viewModel.members.map { add(member: $0) }
    }
    
    fileprivate func updatePerspectiveButtonIcon() {
        switch perspective {
        case .threeD:
            perspectiveButton.setImage(R.image.twoDimensionProjection(), for: .normal)
        case .twoD:
            perspectiveButton.setImage(R.image.threeDimensionProjection(), for: .normal)
        }
    }
    
    func animate(to perspective: ARMapPerspective) {
        guard let mapView = mapView else {
            assertionFailure("MapView has to be initiated")
            return
        }
        
        switch perspective {
        case .threeD:
            mapView.animate(toViewingAngle: viewingAngle)
        case .twoD:
            mapView.animate(toViewingAngle: 0)
        }
        
        updatePerspectiveButtonIcon()
        print("TODO: switch all the markers to the proper perspective")
//        eventTimeMarker?.perspective = perspective
//        for var pointOfInterestMarker in pointOfInterestMarkers {
//            pointOfInterestMarker.perspective = perspective
//        }
        
        for var polygonOverlay in polygonOverlays {
            polygonOverlay.perspective = perspective
        }
    }
    
    func memberMarkerInfoView() -> UIView? {
        if membersMarkerInfoVC != nil {
            return membersMarkerInfoVC.view
        }
        
        self.membersMarkerInfoVC = MapsMarkerInfoVC.instantiate()
        if let markerInfoView = membersMarkerInfoVC.view {
            mapView.addSubview(markerInfoView)
            
            markerInfoView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            markerInfoView.bottomAnchor.constraint(equalTo: mapView.centerYAnchor, constant:-44).isActive = true
            markerInfoView.isHidden = true
            return membersMarkerInfoVC.view
        }
        
        return nil
    }
    
    func hideMarkerInfo() {
        guard let markerInfoWindow = memberMarkerInfoView() else { return }
        
        markerInfoWindow.isHidden = true
    }
    
    func showMarkerInfo(for person: ARPerson) {
        guard let markerInfoWindow = memberMarkerInfoView() else { return }
        membersMarkerInfoVC.person = person
        markerInfoWindow.isHidden = false
    }
    
    func updateLitMeter(place: ARGooglePlace)
    {
        if(!place.litMeterEnabled!) {
            return
        }
        
        var p: POIItem?
        for poi in pointOfInterestMarkers {
            if(poi.place.placeId == place.placeId)
            {
                clusterManager.remove(poi)
                p = poi
                break
            }
        }
        if(p != nil) {
            pointOfInterestMarkers.remove(p!)
        }
        self.viewModel.poiStore.poiSet.remove(place.placeId)
        add(poi: place)
    }
}

// MARK: - Event Handlers

extension MapsVC {
    @IBAction func animateToCurrentLocation(_ sender: Any) {
        if let location = self.mylocation?.position {
            mapView.animate(toLocation: CLLocationCoordinate2DMake(location.latitude, location.longitude))
            if mapView.camera.zoom < defaultZoomLevel {
                mapView.animate(toZoom: defaultZoomLevel)
            }
        }
    }

    @IBAction func togglePerspective(_ sender: Any) {
        switch perspective {
        case .threeD:
            perspective = .twoD
        case .twoD:
            perspective = .threeD
        }
    }
    
    @IBAction func createBubbleButtonPressed(_ sender: AnyObject) {
        // 1- Close bubbles list.
        showBubblesList(show: false, animated: true)
        
        // 2- Present Create Bubble screen.
        let createBubbleVC = CreateBubbleVC.instantiate()
        createBubbleVC.delegate = self
        let navController = UINavigationController(rootViewController: createBubbleVC)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func createMeetingButtonPressed(_ sender: Any) {
        if let _ = ARPlatform.shared.userSession?.bubbleStore.activeBubble {
            showMeetingList(show: true)
        } else {
            SVProgressHUD.showError(withStatus: "Must create a Bubble before adding a Meet Spot!")
            print("activeBubble not set in createmeetingButtonPushed")
        }
    }
    
}

// MARK: - Networking

extension MapsVC {
    
    fileprivate func getMeeting(meeting: ARMeeting, callback: ((ARMeeting, Error?) -> Void)?) {
        SVProgressHUD.show()
        let getMeetingReq = GetMeetingRequest(platform: platform, meeting: meeting)
        let _ = networkSession?.send(getMeetingReq) { result in
            switch result {
            case .success(let meeting):
                SVProgressHUD.dismiss()
                callback?(meeting, nil)
            case .failure(let error):
                SVProgressHUD.dismiss()
                callback?(meeting, error)
            }
        }
    }
}

// MARK: - Map View Delegate Implementation

extension MapsVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let userData = marker.userData else { return false }
        
        let point = mapView.projection.point(for: marker.position)
        let camera = mapView.projection.coordinate(for: point)
        let position = GMSCameraUpdate.setTarget(camera)
        mapView.animate(with: position)
        
        switch userData {
        case let person as ARPerson:
            showMarkerInfo(for: person)
        case let pointOfInterest as ARGooglePlace:
            poiCardVC?.setup(poi: pointOfInterest)
            showPOICard(show: true)
        case let poiItem as POIItem:
            poiCardVC?.setup(poi: poiItem.place)
            showPOICard(show: true)
        case let meeting as ARMeeting:
            self.getMeeting(meeting: meeting) { (meeting, error) in
                if let er = error {
                    print("Error: ", er)
                }
                self.MeetingListDidSelect(meeting: meeting)

            }
        default:
            print("Unsupported map marker tapped.")
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideMarkerInfo()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if let date = self.lastTimestamp, Date().timeIntervalSince(date) > 10 {
            if let lastloc = self.lastlocationFetched {
                let camerralocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
                if lastloc.distance(from: camerralocation) > 1000 {
                    lastlocationFetched = camerralocation
                    lastTimestamp = Date()
                    addTempOverlays(location: camerralocation)
                }

            }
        }
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
    {
        if(gesture) {
            hideMarkerInfo()
        }
    }
}

// MARK: - Create Bubble Delegate Implementation

extension MapsVC: CreateBubbleDelegate {
    
    func createBubbleDidCancel(controller: CreateBubbleVC) {
        dismiss(animated: true, completion: nil)
    }
    
    func createBubbleDidComplete(controller: CreateBubbleVC, bubble: ARBubble) {
        dismiss(animated: true, completion: nil)
        mapsBubblesVC?.bubbleStore?.activeBubble = bubble
        mapsBubblesVC?.refreshBubbleData()
        mapsBubbleBar.refresh(using: mapsBubblesVC?.bubbleStore)
    }
    
}

// MARK: - Create Meeting Delegate Implementation

extension MapsVC: CreateMeetingDelegate {
    
    func createMeetingDidCancel(controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //TODO (felipe): update map
    func createMeetingDidComplete(controller: UIViewController, meeting: ARMeeting) {
        print("createMeetingDidComplete")
        mapsBubblesVC?.refreshBubbleData()
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - BubblesListDelegate Implementation

extension MapsVC: BubblesListDelegate {
    
    func bubblesListDidReloadData(controller: BubblesListVC) {
        mapsBubbleBar.refresh(using: controller.bubbleStore)
        if(controller.bubbleStore?.activeBubble != nil) {
            showMeetingIcons(show: true, bubble: (controller.bubbleStore?.activeBubble)!)
            getBubbleMembers(controller: controller)
        }
    }
    
    func bubblesListDidSelect(controller: BubblesListVC, bubble: ARBubble) {
        controller.bubbleStore?.activeBubble = bubble
        mapsBubbleBar.refresh(using: controller.bubbleStore)
        showBubblesList(show: false, animated: true)
        showMeetingIcons(show: true, bubble: bubble)
        getBubbleMembers(controller: controller)
    }
    
    func bubblesListCreateBubbleButtonPressed(controller: BubblesListVC) {
        createBubbleButtonPressed(controller.emptyStateButton)
    }
    
    func bubblesListDismissedWithNoSelection(controller: BubblesListVC) {
        showBubblesList(show: false, animated: true)
    }
    
    func getBubbleMembers(controller: BubblesListVC) {
        print("getting active bubble members for bubble \(String(describing: controller.bubbleStore?.activeBubble?.identifier))")
        let getBubbleMembersReq = GetBubbleMembersRequest(platform: ARPlatform.shared, bubbleId: (controller.bubbleStore?.activeBubble?.identifier)!)
        let networkSession = ARNetworkSession.shared
        let _ = networkSession.send(getBubbleMembersReq) { result in
            switch result {
            case .success(let members):
                self.showMemberIcons(show: true, people: members)
            case .failure(let error):
                print("ERROR: getting bubble member data: \(error)")
            }
        }
    }
}

// MARK: - MapsBubbleBarDelegate Implementation

extension MapsVC: MapsBubbleBarDelegate {
    
    func mapsBubbleBarDidPressMainButton(controller: MapsBubbleBar) {
        if let _ = platform.userSession?.bubbleStore.activeBubble {
            toggleBubblesList(animated: true)
        } else {
            createBubbleButtonPressed(controller.titleButton)
        }
    }
    
    func mapsBubbleBarDidPressArrowButton(controller: MapsBubbleBar) {
        toggleBubblesList(animated: true)
    }
    
}

// MARK: - POICardDelegate Implementation

extension MapsVC: POICardDelegate {
    
    func poiCardWillClose() {
        showPOICard(show: false)
    }
    
    func poiCardWillShowDetail(pointOfInterest: ARGooglePlace?) {
        showPOICard(show: false)
        if let poi = pointOfInterest {
            navigateToPOIDetails(pointOfInterest: poi)
        }
    }
}

// MARK: - MeetingRSVPDelegate Implementation

extension MapsVC: MeetingRSVPViewDelegate {

    func MeetingRSVPDidSelect(meeting: ARMeeting) {
        if let rsvpListVC = UIStoryboard(name: "RSVPList", bundle: nil).instantiateViewController(withIdentifier: "rsvpTableVC") as? RSVPTableViewController,
            let activeBubble = ARPlatform.shared.userSession?.bubbleStore.activeBubble {
            rsvpListVC.meeting = meeting
            rsvpListVC.bubble = activeBubble

            rsvpListVC.navigationItem.title = meeting.title

            show(rsvpListVC, sender: self)
        }
    }
}

// MARK: - MeetingListCardDelegate Implementation

extension MapsVC: MeetingListCardDelegate {

    
    func MeetingListDidSelect(meeting: ARMeeting) {
        let eventView = MeetingRSVPCardView.instanceFromNib()
        eventView.frame = self.view.bounds
        eventView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(eventView)
        self.view.bringSubview(toFront: eventView)
        
        let meetingView = eventView.cardContainer as! MeetingRSVPView
        var status = ARMeetingRVSPStatus.unanswered
        if (meeting.rsvps!.contains(ARPlatform.shared.userSession!.user!)) {
            status = ARMeetingRVSPStatus.going
        }
        if let activeBubbleMembers = ARPlatform.shared.userSession?.bubbleStore.activeBubble?.members {
            meetingView.setMeeting(meeting: meeting, status: status, members: activeBubbleMembers)
        } else {
            meetingView.setMeeting(meeting: meeting, status: status, members: [])
        }
        meetingView.delegate = self
    }
    
    func MeetingListWillClose() {
        self.showMeetingList(show: false)
    }
    
    func MeetingListWillCreateNewMeeting() {
        if let activeBubble = ARPlatform.shared.userSession?.bubbleStore.activeBubble {
            self.showMeetingList(show: false)
            let createMeetingVC = CreateMeetingVC.instantiate()
            createMeetingVC.bubble = activeBubble
            createMeetingVC.delegate = self
            let navController = UINavigationController(rootViewController: createMeetingVC)
            present(navController, animated: true, completion: nil)
        } else {
            print("activeBubble not set in MeetingListWillCreateNewMeeting")
        }
    }
    
}

// MARK: - location Implementatio
extension MapsVC {

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension MapsVC: CLLocationManagerDelegate {

    // this is used to show MY user location on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if mylocation == nil {
                mylocation = GMSMarker(position: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
                mylocation?.userData = ARPlatform.shared.userSession?.user
                mylocation?.icon = R.image.myLocationMarker()
                mylocation?.isFlat = true
                mylocation?.map = mapView
                addTempOverlays(location: location)
                lastlocationFetched = location
                lastTimestamp = Date()
                mylocation?.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                mapView.animate(toLocation: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
                if mapView.camera.zoom < defaultZoomLevel {
                    mapView.animate(toZoom: defaultZoomLevel)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager didFailWithError: \(error)")
    }
}
