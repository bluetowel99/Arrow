
import UIKit

class SpecialPhotoViewController: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.pOIDetails()
    static var kStoryboardIdentifier: String? = "SpecialPhotoViewController"
    
    @IBOutlet var specialNameLabel: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var specialImage: UIImageView!
    
    var placeName = ""
    var subCategory = ""
    var special: [String: Any]?
    
    var imageUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = imageUrl {
            specialImage.setImage(from: url)
            specialNameLabel.text = ""
            subtitle.text = ""
        }
        else {
            specialNameLabel.text = special!["name"] as? String ?? ""
            subtitle.text = "\(subCategory) - \(placeName)"
            specialImage.setImage(from: URL.init(string: special!["photo"] as? String ?? "")!)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
