
import UIKit

final class POIFillWebsiteVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.pOIFillWebsite()
    static var kStoryboardIdentifier: String? = "POIFillWebsiteVC"

    @IBOutlet weak var websiteTextView: UITextView!
    @IBOutlet weak var submitButton: ARButton!

    @IBOutlet weak var textViewContainer: UIView!

    var place: ARGooglePlace?
      override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlace()
    }


    @IBAction func submitAction(_ sender: Any) {
        if let place = self.place {
            self.editPlace(placeid: place.placeId, website: websiteTextView.text)
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - UI Helpers

extension POIFillWebsiteVC {

    fileprivate func setupView() {
        self.submitButton.layer.cornerRadius = 5.0
        self.submitButton.layer.borderWidth = 4.0
        self.submitButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
        self.textViewContainer.layer.cornerRadius = 11.0
    }

    fileprivate func setupPlace() {
        navigationBarTitle = place?.name
    }
}

extension POIFillWebsiteVC {
    fileprivate func editPlace(placeid: String, website: String) {
        let request = EditPlaceRequest(platform: ARPlatform.shared, googlePlaceId: placeid, field: "website", value: website)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let b):
                print("success \(b)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
