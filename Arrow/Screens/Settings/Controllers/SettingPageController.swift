
import Foundation

// MARK: - SettingPageController Definition

protocol SettingPageController: class {
    
    static var model: ARSettingPage { get }
    
    var platform: ARPlatform! { get set }
    var networkSession: ARNetworkSession! { get set }
    var options: [ARSettingOption] { get set }
    var navigationBarTitle: String { get }
    var menuTitle: String { get }
    var refreshCallback: (([ARSettingOption]) -> Void)? { get set }
    
    func refresh()
    func settingPageDidSelect(controller: SettingPageVC, optionIndex: UInt)
    
}

// MARK: - Default Implementations

extension SettingPageController {
    
    var navigationBarTitle: String {
        return Self.model.navigationBarTitle
    }
    
    var menuTitle: String {
        return Self.model.menuTitle
    }
    
}

// MARK: - Helper Methods

extension SettingPageController {
    
    func navigateToSettingPage(pageController: SettingPageController, from controller: ARViewController) {
        let settingPageVC = SettingPageVC.instantiate()
        settingPageVC.pageController = pageController
        controller.navigationController?.pushViewController(settingPageVC, animated: true)
    }
    
    func updateOptions<T: RawRepresentable>(for option: T, withType type: ARSettingOptionType) {
        guard let rawValue = option.rawValue as? UInt else {
            return
        }
        
        let index = Int(rawValue)
        options[index] = options[index].with(type: type)
    }
    
}

// MARK: - Networking Helpers

extension SettingPageController {
    
    func updateMySettings(_ settings: ARSettings, callback: ((NSError?) -> Void)?) {
        let request = UpdateMySettingsRequest(platform: platform, settings: settings)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error as NSError)
            }
        }
    }
    
}
