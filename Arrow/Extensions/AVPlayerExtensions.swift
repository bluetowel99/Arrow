
import AVFoundation

extension AVPlayer {
    
    func setRepeat(enabled repeatEnabled: Bool) {
        if repeatEnabled == true {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [unowned self] notification in
                self.seek(to: kCMTimeZero)
                self.play()
            }
        } else {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }
    
}
