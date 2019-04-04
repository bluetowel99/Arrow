
import UIKit
import Localide

class CheckInCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    let errorMessage = "Couldn't retrive data"
    var poi: ARGooglePlace?

    override func prepareForReuse() {
        super.prepareForReuse()

        photoImageView.image = nil
        nameLabel.text = "Loading..."
        dateLabel.text = ""
    }

    @IBAction func navigationButtonPressed(_ sender: Any) {
        if let destination = poi {
            let location = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            Localide.sharedManager.promptForDirections(toLocation: location,  rememberPreference: true, onCompletion: nil)
        } else {
            print("Point of inerest not loaded yet")
//            SVProgressHUD.error(string: "Address not loaded yet, please try again in a bit")
        }
    }


    func setupCell(checkInInfo checkIn: ARCheckIn) -> Void {
        if let placeId = checkIn.placeId, let timestamp = checkIn.timeStamp  {
            nameLabel.text = "Loading..."
            setPOI(placeId: placeId)
            dateLabel.text = timestamp.asEnglish()
        } else {
            nameLabel.text = errorMessage
            self.photoImageView.image = nil
            dateLabel.text = ""
        }
    }

    private func setPOI(placeId: String) {
        retrievePOI(placeId: placeId) { poi, error in
            if let error = error {
                print("Error fetching user check ins: \(error.localizedDescription)")
                return
            }
            if let pointOfInterest = poi {
                self.poi = pointOfInterest
                self.nameLabel.text = pointOfInterest.name
                self.setPOIImage(poi: pointOfInterest)
            } else {
                self.nameLabel.text = "Couldn't Retrieve"
                self.photoImageView.image = nil
            }
        }
    }

    private func retrievePOI(placeId: String, callback: ((ARGooglePlace?, NSError?) -> Void)?) {
        let request = GetPlaceRequest(platform: ARPlatform.shared, placeId: placeId)
        let _ = ARNetworkSession.shared.send(request) { result in
            switch result {
            case .success(let poi):
                callback?(poi, nil)
            case .failure(let error):
                print("getArrowPOIData ERROR: \(error)")
                callback?(nil, error as NSError)
            }
        }
    }

    private func setPOIImage(poi: ARGooglePlace) {
        if let photos = poi.photos, photos.isEmpty == false, let url = photos.first?.url {
            self.photoImageView.setImage(from: url)
        } else {
            self.photoImageView.image = nil
        }
    }
}
