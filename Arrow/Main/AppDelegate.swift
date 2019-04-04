

import UIKit
import UserNotifications

import GoogleMaps
import FirebaseCore
import FirebaseMessaging
import IQKeyboardManagerSwift
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(ARConstants.GooglePlace.key)
        
        IQKeyboardManager.shared.enable=true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40.0
        
        FirebaseApp.configure()
        reloadUserProfileFromServer() // Must call otherwise ID seems to be nil
        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        setupWindow()
        configureProgressView()
        
        // NOT SURE WE NEED THIS, BUT NOT READY TO REMOVE IT
        // Notification settings referenced from https://youtu.be/LBw5tuTvKd4?t=653
//        let notificationTypes : UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
//        let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
//        application.registerForRemoteNotifications()
//        application.registerUserNotificationSettings(notificationSettings)
        
        return true
    }
    
}

fileprivate func reloadUserProfileFromServer() {
    var platform: ARPlatform = ARPlatform.shared
    var networkSession: ARNetworkSession? = ARNetworkSession.shared
    platform.refreshUserProfile(networkSession: networkSession) { error in
        if let error = error {
            print("Error fetching user profile: \(error.localizedDescription)")
            return
        }
    }
}

// MARK: - Notifications

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("Application registred for notifications: \(notificationSettings.types)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let characterSet = CharacterSet(charactersIn: "<>")
//        let deviceTokenString = deviceToken.description.trimmingCharacters(in: characterSet).replacingOccurrences(of: " ", with: "")
        print("APNs device token retrieved: \(deviceToken as NSData)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Application failed to register for push notifications.")
        print("Error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        //print("MessageID : \(userInfo["gcm_message_id"])")
        //print(userInfo)
        print("Notication received")
    }
    
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices while app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("userNoticiationCenter willPresent")
        
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        ARPlatform.shared.userSession?.bubbleStore.bubblesListVC?.reloadBubbleData()
        ARPlatform.shared.userSession?.threadStore.messagingInboxVC?.fetchThreadList(forceReload: true)

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        // this seems to ensure that the notification is hidden completely while app is in foreground - no badge/sound/etc
        completionHandler([])
    }
    
    // Handle notification messages after display notification is tapped by the user
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("userNoticiationCenter didReceive")
        
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)
        
        print("completionHandler: \(completionHandler)")

        completionHandler()
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : MessagingDelegate {
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("FCM registration token: \(fcmToken)");
        
        if(ARPlatform.shared.sessionMode == .loggedIn)
        {
            let request = UpdateMyDeviceRequest(platform: ARPlatform.shared, token: fcmToken)
            let networkSession = ARNetworkSession.shared
            let _ = networkSession.send(request) { result in
                switch result {
                case .success(_):
                    print("SUCCESS: token data sent to server - ready for push notifications")
                case .failure(let error):
                    print("ERROR: token data send error: \(error)")
                }
            }
        }
    }

    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
// [END ios_10_data_message_handling]
