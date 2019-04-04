
import AVFoundation
import CoreLocation
import Contacts
import Photos
import UIKit

final class PermissionSettingsController: SettingPageController {
    
    typealias T = PermissionSettingsPageOptions
    static var model: ARSettingPage = PermissionSettingsPage()
    
    var platform: ARPlatform!
    var networkSession: ARNetworkSession!
    var options = model.options
    var refreshCallback: (([ARSettingOption]) -> Void)?
    
    func refresh() {
        
        let locationStatus = CLLocationManager.authorizationStatus()
        let hasLocationAccess = locationStatus  == .authorizedWhenInUse || locationStatus == .authorizedAlways
        let hasContactsAccess = CNContactStore.authorizationStatus(for: .contacts) == .authorized
        let hasCameraAccess = AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
        let hasPhotosAccess = PHPhotoLibrary.authorizationStatus() == .authorized
        
        updateOptions(for: T.location, withType: hasLocationAccess ? .switchOn : .switchOff)
        updateOptions(for: T.contatcs, withType: hasContactsAccess ? .switchOn : .switchOff)
        updateOptions(for: T.cameraAndMic, withType: hasCameraAccess ? .switchOn : .switchOff)
        updateOptions(for: T.photos, withType: hasPhotosAccess ? .switchOn : .switchOff)
        
        refreshCallback?(options)
    }
    
    func settingPageDidSelect(controller: SettingPageVC, optionIndex: UInt) {
        guard let option = T(rawValue: optionIndex) else {
            print("Selected index does not map to a valid page option.")
            return
        }
        
        switch option {
        case .cameraAndMic, .contatcs,  .location, .photos:
            // Open app's iOS settings screen.
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            platform.openURL(settingsUrl)
        }
    }
    
}
