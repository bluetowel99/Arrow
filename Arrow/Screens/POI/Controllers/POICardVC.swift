
import UIKit
import SVProgressHUD
import Localide

protocol POICardDelegate {
    func poiCardWillClose()
    func poiCardWillShowDetail(pointOfInterest: ARGooglePlace?)
}

final class POICardVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.pOICard()
    static var kStoryboardIdentifier: String? = "POICardVC"
    
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var poiTitleLabel: UILabel!
    @IBOutlet weak var flamesStackView: UIStackView!
    @IBOutlet weak var numberRatingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var openUntilLabel: UILabel!
    @IBOutlet weak var poiAddressLabel: UILabel!
    @IBOutlet weak var poiPhoneNumberLabel: UILabel!
    @IBOutlet weak var poiWebpageLabel: UILabel!
    @IBOutlet weak var viewDetailButton: ARButton!
    @IBOutlet weak var blurredBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIImageView!
    @IBOutlet weak var contactInfoActivityIndicator: UIActivityIndicatorView!

    // POI Image
    @IBOutlet weak var poiImageView: UIImageView!
    @IBOutlet weak var poiImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var poiImageViewBottomConstraint: NSLayoutConstraint!


    private(set) var poi: ARGooglePlace?
    var delegate: POICardDelegate?
    var poiLocationAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setup(poi: ARGooglePlace) {
        self.poi = poi
        resetFields()
        updateBasicFields()

        contactInfoActivityIndicator.startAnimating()
        self.poi?.placeId = "ChIJeTAC53zqxokRt2TToS8zc7k"
        self.viewDetailButton.isEnabled = false
        getPlaceDetails(placeId: (self.poi?.placeId)!) { (googlePlace, error) in
            
            if let place = googlePlace {
                self.poi?.copyNonNilData(newPOI: place)
            }
            self.viewDetailButton.isEnabled = true
            self.setupRating()
            self.updateDetailFields()
            self.contactInfoActivityIndicator.stopAnimating()
        }
    }
}

// MARK: - UI Helpers

extension POICardVC {
    
    fileprivate func setupView() {
        setupBackgroundBlur()
        cardContainerView.layer.cornerRadius = 5.0
        view.backgroundColor = .clear
    }
    
    fileprivate func setupBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredBackgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredBackgroundView.addSubview(blurEffectView)
        blurredBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction(_:))))
    }
    
    fileprivate func updateBasicFields() {
        guard let poi = poi else { return }

        poiTitleLabel.text = poi.name

        if let address = poi.address {
            self.poiAddressLabel.text = address
            self.poiLocationAddress = address
        } else {
            let locationManager = ARPlatform.shared.locationManager
            locationManager.getPlacemarks(for: CLLocation(latitude: poi.latitude, longitude: poi.longitude), completion: { [weak self] placemarks, error in
                if let error = error {
                    print("Error loading MapsMarkerInfoVC address: \(error.localizedDescription)")
                    return
                }

                let address = locationManager.getFormattedAddress(for: placemarks?.first)
                self?.poiAddressLabel.text = address
                self?.poiLocationAddress = address
            })
        }

        if let photos = poi.photos, photos.isEmpty == false, let url = photos.first?.url {
            activityIndicator.startInfiniteRotationAnimation()
            poiImageViewTopConstraint.constant = 0
            poiImageViewBottomConstraint.constant = 0
            self.poiImageView.contentMode = .scaleAspectFill
            self.poiImageView.setImage(from: url, placeholder: nil, completion: {
                self.activityIndicator.stopInfiniteRotationAnimation()
            })
        } else {
            poiImageViewTopConstraint.constant = 20
            poiImageViewBottomConstraint.constant = 20
            poiImageView.contentMode = .scaleAspectFit
            poiImageView.image = #imageLiteral(resourceName: "PlaceholderImage")
        }
    }
    
    func updateDetailFields() {
        guard let poi = self.poi else { return }

        poiWebpageLabel.text = poi.website ?? "- N/A"
        poiPhoneNumberLabel.text = poi.phone ?? "- N/A"
        descriptionLabel.text = poi.types?.first?.displayName ?? ""

        // Price level.
        let attributedString = NSMutableAttributedString(string: "$$$$", attributes: [NSAttributedStringKey.foregroundColor: R.color.arrowColors.silver()])
        let boldFontAttribute = [NSAttributedStringKey.foregroundColor: UIColor.black]
        
        // Bolden part of string.
        let priceLevel = poi.priceLevel ?? 0
        attributedString.addAttributes(boldFontAttribute, range: NSMakeRange(0, priceLevel))
        priceLabel.attributedText = attributedString

        openUntilLabel.isHidden = false
        if let closingTime = poi.getClosingTime() {
            openUntilLabel.text = closingTime
        } else {
            openUntilLabel.text = "N/A"
            openUntilLabel.textColor = UIColor.gray
        }

        if let locationAddress = poiLocationAddress {
            self.poi?.address = locationAddress
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func setupRating() {
        // Filling flame icons.
        let _ = flamesStackView.arrangedSubviews.enumerated().map { index, element in
            guard let flameIcon = element as? UIImageView else { return }
            let index = Float(index + 1)
            let rating = self.poi?.rating ?? 0.0

            if rating >= index {
                flameIcon.image = R.image.ratingFlameFilled()
            } else if (index - rating) < 0.5 {
                flameIcon.image = R.image.ratingFlameHalf()
            } else {
                flameIcon.image = R.image.ratingFlameEmpty()
            }
        }
    }
    
    func resetFields() {
        poiImageView.image = nil
        poiWebpageLabel.text = nil
        poiAddressLabel.text = nil
        poiPhoneNumberLabel.text = nil
        openUntilLabel.text = nil
        openUntilLabel.isHidden = true
        priceLabel.text = " "
        let _ = flamesStackView.subviews.map {
            guard let flameIcon = $0 as? UIImageView else { return }
            flameIcon.image = R.image.ratingFlameEmpty()
        }
    }
    
}

// MARK: - Event Handlers

extension POICardVC {
    
    @IBAction func viewDetailAction(_ sender: Any) {
        delegate?.poiCardWillShowDetail(pointOfInterest: poi)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        delegate?.poiCardWillClose()
    }

    @IBAction func blueArrowTapped(_ sender: Any) {
        if let destination = poi {
            let location = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
            Localide.sharedManager.promptForDirections(toLocation: location,  rememberPreference: true, onCompletion: nil)
        } else {
            print("Couldn't retrieve POI")
        }
    }

}

// MARK: - Networking

extension POICardVC {
    
    fileprivate func getPlaceDetails(placeId: String, callback: ((ARGooglePlace?, NSError?) -> Void)?) {
        let request = GetPlaceRequest(platform: platform, placeId: placeId)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let place):
                callback?(place, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}
