
import AVFoundation
import Contacts
import CoreLocation
import Photos
import UIKit
import UserNotifications

final class SignupPermissionsVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.signupPermissions()
    
    @IBOutlet weak var notificationButton: ARButton!
    @IBOutlet weak var locationButton: ARButton!
    @IBOutlet weak var contactsButton: ARButton!
    @IBOutlet weak var cameraButton: ARButton!
    @IBOutlet weak var microphoneButton: ARButton!
    @IBOutlet weak var photosButton: ARButton!
    @IBOutlet weak var actionButton: UIButton!
    var permissionButtons: [ARButton]!
    
    let locationManager = CLLocationManager()
    let contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarBackTextHidden = true
        navigationBarTitle = "Create Your Profile"
        setupView()
        setLocalizableStrings()
        setInitialPermissionStates()
    }
    
}

// MARK: - UI Helpers

extension SignupPermissionsVC {
    
    fileprivate func setupView() {
        permissionButtons = [notificationButton, locationButton, contactsButton, cameraButton, microphoneButton, photosButton]
        let _ = permissionButtons.map {
            $0.layer.cornerRadius = 3.0
        }
    }
    
    fileprivate func setLocalizableStrings() { }
    
    fileprivate func setInitialPermissionStates() {
        // TODO(kia): Determine notification's current status.
        
        let locationStatus = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        updatePermissionButton(locationButton, selected: locationStatus)
        
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts) == .authorized
        updatePermissionButton(contactsButton, selected: contactStatus)
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        updatePermissionButton(cameraButton, selected: cameraStatus)
        
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .authorized
        updatePermissionButton(microphoneButton, selected: microphoneStatus)
        
        let photosStatus = PHPhotoLibrary.authorizationStatus() == .authorized
        updatePermissionButton(photosButton, selected: photosStatus)
    }
    
    fileprivate func updatePermissionButton(_ button: UIButton, selected: Bool) {
        button.isSelected = selected
        button.isUserInteractionEnabled = !selected
    }
    
}

// MARK: - Permission Helper Methods

extension SignupPermissionsVC {
    
    func requestNotificationPermission() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                    return
                }
                
                print("Notifications permission granted == \(granted)")
            }
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func requestLocationPermission() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestContactsPermission() {
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            contactStore.requestAccess(for: .contacts, completionHandler: { granted, error in
                if let error = error {
                    print("Conatcs permission error: \(error.localizedDescription)")
                    return
                }
                
                print("Contacts permission granted == \(granted)")
            })
        }
    }
    
    private func requestMediaPermission(forMediaType mediaType: String) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: mediaType)) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: mediaType)) { granted in
                print("Media type (\(mediaType)) permission granted == \(granted)")
            }
        }
    }
    
    func requestCameraPermission() {
        requestMediaPermission(forMediaType: AVMediaType.video.rawValue)
    }
    
    func requestMicrophonePermission() {
        requestMediaPermission(forMediaType: AVMediaType.audio.rawValue)
    }
    
    func requestPhotosPermission() {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                print("Photos permission status: \(status)")
            }
        }
    }
    
}

// MARK: - Event Handlers

extension SignupPermissionsVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        platform.requestRootViewControllerUpdate(switchingToLoggedInMode: true)
    }
    
    @IBAction func notificationsButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestNotificationPermission()
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestLocationPermission()
    }
    
    @IBAction func contactsButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestContactsPermission()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestCameraPermission()
    }
    
    @IBAction func microphoneButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestMicrophonePermission()
    }
    
    @IBAction func photosButtonPressed(_ sender: UIButton) {
        updatePermissionButton(sender, selected: !sender.isSelected)
        requestPhotosPermission()
    }
    
}
