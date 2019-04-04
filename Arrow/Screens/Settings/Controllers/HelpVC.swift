
import UIKit
import MessageUI
import SVProgressHUD

final class HelpVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.help()
    static var kStoryboardIdentifier: String? = "HelpVC"
    
}

// MARK: - Event Handlers

extension HelpVC: MFMailComposeViewControllerDelegate {
    
    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        let emailTitle = "Support"
        let toRecipents = ["help@goarrow.io"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody("", isHTML: false)
        mc.setToRecipients(toRecipents)

        self.present(mc, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            SVProgressHUD.showSuccess(withStatus: "")
            print("Mail sent")
        case .failed:
            SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "Failed to send email")
            print("Mail sent failure: \(error?.localizedDescription ?? "Failed to send email")")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
