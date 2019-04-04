
import UIKit

final class SignupCongratsVC: ARViewController, NibViewController {
    
    static var kNib: UINib = R.nib.signupCongrats()
    
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        isNavigationBarBackTextHidden = true
        navigationBarTitleStyle = .fullLogo
        setLocalizableStrings()
    }
    
}

// MARK: - UI Helpers

extension SignupCongratsVC {
    
    fileprivate func setLocalizableStrings() {
        actionButton.setTitle("EDIT YOUR PROFILE", for: .normal)
    }
    
}

// MARK: - Event Handlers

extension SignupCongratsVC {
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        let profilePictureVC = SignupProfilePictureVC.instantiate()
        navigationController?.pushViewController(profilePictureVC, animated: true)
    }
    
}
