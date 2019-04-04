
import UIKit

final class MessagingEmptyInboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlsBackgroundView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
}

extension MessagingEmptyInboxTableViewCell {
    
    fileprivate func setupView() {
        controlsBackgroundView.layer.borderColor = ARButton.Appearance.enabledBorderColor.cgColor
        controlsBackgroundView.layer.borderWidth = ARButton.Appearance.borderWidth
        controlsBackgroundView.layer.cornerRadius = ARButton.Appearance.cornerRadius
        
        if let url = Bundle.main.url(forResource: "EmptyMessagesInformativeText", withExtension: "rtf") {
            let contents: NSAttributedString
            do {
                contents = try NSAttributedString.init(url: url, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                self.textView.attributedText = contents
            } catch let error {
                print("Error accessing EmptyMessagesInformativeText.rtf:")
                print(error)
            }
        } else {
            textView.text = R.string.messaging.messagingIntroInformativeTextBackupLabel()
        }
    }
    
}
