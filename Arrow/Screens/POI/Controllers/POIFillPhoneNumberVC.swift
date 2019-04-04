
import UIKit

final class POIFillPhoneNumberVC: ARViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.pOIFillPhoneNumber()
    static var kStoryboardIdentifier: String? = "POIFillPhoneNumberVC"

    @IBOutlet weak var submitButton: ARButton!
    @IBOutlet weak var phoneNumberTextView: UITextView!

    @IBOutlet weak var textViewContainer: UIView!
    var place: ARGooglePlace?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPlace()
    }


    @IBAction func submitAction(_ sender: Any) {
        if let place = self.place {
            self.editPlace(placeid: place.placeId, phoneNumber: phoneNumberTextView.text)
            self.navigationController?.popViewController(animated: true)
        }
    }

}

// MARK: - UI Helpers

extension POIFillPhoneNumberVC {

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

extension POIFillPhoneNumberVC {
    fileprivate func editPlace(placeid: String, phoneNumber: String) {
        let request = EditPlaceRequest(platform: ARPlatform.shared, googlePlaceId: placeid, field: "formatted_phone_number", value: phoneNumber)
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
