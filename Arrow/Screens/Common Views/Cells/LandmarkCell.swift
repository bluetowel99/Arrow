
import CoreLocation
import UIKit
import Localide

class LandmarkCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var navigateButton: UIButton!
    
    private(set) var place: ARGooglePlace?
    var delegate: LandmarkCellDelegate?
    
    func setupCell(landmark place: ARGooglePlace, localizedDistance: String?, thumbnailWidth: CGFloat) -> Void {
        selectionStyle = .none
        
        self.place = place
        
        photoImageViewWidthConstraint.constant = thumbnailWidth
        
        if let imageURL = place.photos?.first?.url {
            photoImageView.setImage(from: imageURL)
        }
        
        nameLabel.text = place.name
        
        // List up to 3 types for the location.
        let locationTypes: [String]? = place.types?.prefix(3).flatMap { $0.displayName }
        let types = locationTypes?.joined(separator: ", ") ?? ""
        var dollarSigns = ""
        if let priceLevel = place.priceLevel {
            dollarSigns = String(repeating: "$", count: priceLevel) + ", "
        }
        secondLineLabel.text = "\(dollarSigns)\(types)"
        thirdLineLabel.text = localizedDistance
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        place = nil
        photoImageView.image = nil
        nameLabel.text = nil
        secondLineLabel.text = nil
        thirdLineLabel.text = nil
    }
    
}

// MARK: - Event Handlers

extension LandmarkCell {
    
    @IBAction func navigateButtonPressed(_ sender: AnyObject) {
        if let destination = place {
            let location = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            Localide.sharedManager.promptForDirections(toLocation: location,  rememberPreference: true, onCompletion: nil)
        } else {
            print("Couldn't retrieve POI")
        }
    }
    
}

// MARK: - LandmarkCellDelegate Definition

protocol LandmarkCellDelegate {
    func landmarkCellDidPressNavigate(cell: LandmarkCell)
}
