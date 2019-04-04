
import Foundation
import UIKit

final class MessagesMediaDetailsVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.messagesMediaDetails()
    static var kStoryboardIdentifier: String? = "MessagesMediaDetailsVC"

    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var creatorImageView: UIImageView!

    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var userInitialsContainer: UIView!

    @IBOutlet weak var usernameInitialsLabel: UILabel!
    var message: ARMessage?
    var mediaIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userInitialsContainer.layer.cornerRadius = 13
        self.creatorNameLabel.text = message?.displayName
        if let fullName = message?.displayName {
            var fullNameArr = fullName.components(separatedBy: " ")
            if fullNameArr.count >= 2 {
                var personNameComponents = PersonNameComponents()
                personNameComponents.givenName = fullNameArr[0]
                personNameComponents.familyName = fullNameArr[1]
                let personNameFormatter = PersonNameComponentsFormatter()
                personNameFormatter.style = .abbreviated
                usernameInitialsLabel.text = personNameFormatter.string(from: personNameComponents)
            }
        }
        if let media = message?.media, let index = mediaIndex, media.count > index, let url = media[index].url {
            self.mediaImageView.setImage(fromFirebaseUrl: url)
            self.addressLabel.text = media[index].address
            self.placeNameLabel.text = media[index].placeName
        }
    }
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func shaerAction(_ sender: Any) {
        if let image = mediaImageView.image {
            let imageToShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = []
            self.present(activityViewController, animated: true, completion: nil)
        }

    }

}
