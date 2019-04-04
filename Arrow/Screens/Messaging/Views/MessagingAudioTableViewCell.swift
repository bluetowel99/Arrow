
import Foundation
import AVFoundation
import FirebaseStorage

protocol MessagingAudioTableViewCellDelegate {
    func didPressPlayButton(row: Int)
}
class MessagingAudioTableViewCell: UITableViewCell {


    @IBOutlet weak var waveImage: UIImageView!
    @IBOutlet weak var playingTimeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    var audioPlayer: AVPlayer!
    var message: ARMessage?
    var row: Int?
    var delegate: MessagingAudioTableViewCellDelegate?

    var updateTimer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        playingTimeLabel.text = "00:00"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        updateTimer?.invalidate()
        audioPlayer?.replaceCurrentItem(with: nil)
        audioPlayer = nil
        playingTimeLabel.text = "00:00"
    }

    @IBAction func playAction(_ sender: Any) {
        if let _ = audioPlayer {
            playingTimeLabel.text = "00:00"
            updateTimer?.invalidate()
            audioPlayer?.replaceCurrentItem(with: nil)
            audioPlayer = nil
        }
        if let gurl = message?.audioUrl, let row = self.row {
            Storage.storage().reference(forURL: gurl.absoluteString).downloadURL(completion: {(url, error) in
                guard let url = url else {
                    return
                }
                print(url.absoluteString)
                if row == self.row  {
                    do {
                        self.updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MessagingAudioTableViewCell.updateLabel), userInfo: nil, repeats: true)
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        let playerItem = AVPlayerItem(url: url)
                        NotificationCenter.default.addObserver(self,selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                        self.audioPlayer = AVPlayer(playerItem: playerItem)
                        self.audioPlayer.play()
                    } catch {
                         print("caught: \(error)")
                    }
                }
            })
        }
    }

    @objc func updateLabel() {
        let timeInterval = audioPlayer.currentTime()
        self.playingTimeLabel.text = timeInterval.seconds.stringValue
    }

    @objc func playerDidFinishPlaying(sender: Notification) {
        playingTimeLabel.text = "00:00"
        updateTimer?.invalidate()
        audioPlayer?.replaceCurrentItem(with: nil)
        audioPlayer = nil
    }

}
