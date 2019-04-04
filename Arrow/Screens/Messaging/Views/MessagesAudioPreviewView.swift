
import Foundation

protocol MessagesAudioPreviewViewDelegate {
    func deleteAudioPreview()
    func didTapPlayButton()
}
class MessagesAudioPreviewView: UIView {

    var view: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!

    var delegate: MessagesAudioPreviewViewDelegate?

    func setupViews() {
    }

    class func instanceFromNib() -> MessagesAudioPreviewView {
        return UINib(nibName: "MessagesAudioPreviewView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! MessagesAudioPreviewView
    }


    @IBAction func deleteAction(_ sender: Any) {
        self.delegate?.deleteAudioPreview()
    }

    @IBAction func playAction(_ sender: Any) {
        self.delegate?.didTapPlayButton()
    }

}
