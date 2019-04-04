
import UIKit
import SwiftKeychainWrapper

/// Platform manages fundamental data sctructures and high-level flow of the app.

class ARPlatform {
    
    /// Logged-in session modes of the app.
    enum SessionMode {
        case anonymouslyLoggedIn
        case loggedIn
        case loggedOut
    }
    
    /// Singelton instance of Platform.
    static var shared: ARPlatform = {
        return ARPlatform()
    }()
    
    /// Private in-memory copy of userSession, which is persisted in the keychain.
    fileprivate var _userSession: ARUserSession? = nil
    
    /// Authenticated user's active session.
    var userSession: ARUserSession? {
        get { return getUserSession() }
        set { setUserSession(newValue: newValue) }
    }
    
    /// Internally tracking app's logged-in mode.
    fileprivate var _isInLoggedInMode: Bool? = nil
    fileprivate var isInLoggedInMode: Bool {
        get { return getIsInLoggedInMode() }
        set { setIsInLoggedInMode(newValue: newValue) }
    }
    
    /// Platform session's logged-in mode.
    var sessionMode: SessionMode {
        return getSessionMode()
    }
    
    /// Platform's common keychain.
    var keychain = KeychainWrapper.standard
    
    /// Platform's common user defaults.
    var userDefaults = UserDefaults.standard
    
    /// Platform's common contacts store.
    lazy var contactStore = { ARContactStore() }()
    
    /// Platform's common location manager.
    var locationManager = { ARLocationManager() }()
    
    /// App's user settings.
    lazy var userSettings: ARSettings = { ARSettings() }()
    
    /// The reciever's delegate.
    ///
    /// Platform delegate responds to app-level events.
    var delegate: ARPlatformDelegate?
    
    static var mainTabController: MainTabController?
}

// MARK: - Private Implementations

extension ARPlatform {
    
    // MARK: Logged-in Mode Helpers
    
    fileprivate func getSessionMode() -> SessionMode {
        if isInLoggedInMode == true {
            return userSession == nil ? .anonymouslyLoggedIn : .loggedIn
        }
        return .loggedOut
    }
    
    fileprivate func getIsInLoggedInMode() -> Bool {
        if let loggedIn = _isInLoggedInMode {
            return loggedIn
        } else if let loggedIn = keychain.bool(forKey: ARConstants.Keychain.isUserLoggedIn) {
            _isInLoggedInMode = loggedIn
            return loggedIn
        }
        return false
    }
    
    fileprivate func setIsInLoggedInMode(newValue: Bool) {
        _isInLoggedInMode = newValue
        keychain.set(newValue, forKey: ARConstants.Keychain.isUserLoggedIn)
    }
    
    // MARK: User Session Helpers
    
    fileprivate func getUserSession() -> ARUserSession? {
        if let session = _userSession {
            return session
        } else if let sessionDict = keychain.object(forKey: ARConstants.Keychain.userSession) as? Dictionary<String, Any> {
            let session = ARUserSession(with: sessionDict)
            _userSession = session
            return session
        }
        return nil
    }
    
    fileprivate func setUserSession(newValue: ARUserSession?) {
        _userSession = newValue
        guard let newValue = newValue else {
            keychain.removeObject(forKey: ARConstants.Keychain.userSession)
            return
        }
        
        let sessionDict = newValue.dictionaryRepresentation() as NSDictionary
        keychain.set(sessionDict, forKey: ARConstants.Keychain.userSession)
    }
    
}

// MARK: - Private Networking

extension ARPlatform {
    
    fileprivate func fetchProfile(networkSession: ARNetworkSession!, callback: ((ARPerson?, NSError?) -> Void)?) {
        let getMyProfileReq = GetMyProfileRequest()
        let _ = networkSession?.send(getMyProfileReq) { result in
            switch result {
            case .success(let me):
                callback?(me, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }


    fileprivate func fetchCheckIns(networkSession: ARNetworkSession!, callback: (([ARCheckIn?], NSError?) -> Void)?) {
        let getMyProfileReq = GetAllMyCheckInsRequest()
        let _ = networkSession?.send(getMyProfileReq) { result in
            switch result {
            case .success(let checkIns):
                callback?(checkIns, nil)
            case .failure(let error):
                callback?([], error as NSError)
            }
        }
    }
    
}

// MARK: - Public Functions

extension ARPlatform {
    
    /// Signal the need for a root view controller update.
    func requestRootViewControllerUpdate(switchingToLoggedInMode mode: Bool) {
        isInLoggedInMode = mode
        delegate?.platformDidRequestUpdatingRootViewController(platform: self)
    }
    
    func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func callPhoneNumber(_ number: String) {
        let phoneNum = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNum)") {
            openURL(url)
        }
    }
    
    /// Fetches user's profile and sets userSession's user.
    ///
    /// Access fetched user profile from userSession on error-free completion.
    func refreshUserProfile(networkSession: ARNetworkSession!, completion: ((NSError?) -> Void)?) {
        fetchProfile(networkSession: networkSession) { user, error in
            self.userSession?.user = user
            completion?(error)
        }
    }


    /**
     - Retrieves all of the current User's past check ins
    */
    func refreshUserCheckIns(networkSession: ARNetworkSession!, completion: ((NSError?) -> Void)?) {
        fetchCheckIns(networkSession: networkSession) { checkIns, error in
            self.userSession?.checkIns = checkIns.reversed()
            completion?(error)
        }
    }
    
}

// MARK: - ARPlatformDelegate Definition

protocol ARPlatformDelegate {
    
    func platformDidRequestUpdatingRootViewController(platform: ARPlatform)
    
}
