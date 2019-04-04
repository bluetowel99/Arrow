
import Foundation

protocol ARSettingPage {
    
    var navigationBarTitle: String { get }
    var menuTitle: String  { get }
    var options: [ARSettingOption] { get }
    
}
