
import UIKit

protocol RatedSpecialDelegate {
    func specialWasRated(_ special: [String: Any])
}

class RateSpecialViewController: UIViewController, RateButtonsContainerDelegate {
    
    var special = [String: Any]()
    var rating: Float?
    var delegate: RatedSpecialDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func rate(_ sender: Any) {
        
        guard rating != nil else {
            return
        }
        
        let request = RatingRequest.init(platform: ARPlatform.shared, userID: Int((ARPlatform.shared.userSession?.user?.identifier)!)!, item: special["id"] as! Int, rating: rating!)
        let networkSession = ARNetworkSession.shared
        let _ = networkSession.send(request) { result in
            
            switch result {
            case .success(_):
                print("SUCCESS: token data sent to server - ready for push notifications")
                
                var ratings: Array = (self.special["ratings"]! as? Array<[String: Any]>)!
                let newRating = ["user":Int((ARPlatform.shared.userSession?.user?.identifier)!)!, "rating": self.rating!] as [String : Any]
                ratings.append(newRating)
                self.special["ratings"]! = ratings
                self.delegate?.specialWasRated(self.special)
                self.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                print("ERROR: token data send error: \(error)")
            }
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setRating(ratingType: String, rating: Float) {
        self.rating = rating
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "rate" {
            if let destination = segue.destination as? RateButtonsContainerVC {
                destination.delegate = self
                destination.ratingType = ARPlaceRating.Keys.food
            }
        }
    }
}
