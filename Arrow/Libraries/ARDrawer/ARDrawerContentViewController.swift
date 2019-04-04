
import UIKit

class ARDrawerContentViewController: UIViewController {
    weak var drawer: ARDrawer?
    
    override var disablesAutomaticKeyboardDismissal: Bool {
        get {
            return false
        }
        set {}
    }
    
    func maximize() {
        guard let container = drawer,
            let presetation = container.presentationController as? ARDrawerPresentationController else { return }
        presetation.maximize()
    }
    
    func minimize() {
        
    }
    
    func dismiss() {
        guard let drawer = parent as? ARDrawer else { return }
        drawer.dismiss(with: false)
    }
}
