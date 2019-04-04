
import UIKit
import SVProgressHUD
import GrowingTextView

class RatePlaceViewController: ARViewController, UINavigationControllerDelegate {

    var googlePlace: ARGooglePlace!
    var placeRating = ARPlaceRating()

    // ContainerViews
    @IBOutlet weak var experienceContainerView: UIView!
    @IBOutlet weak var foodContainerView: UIView!
    @IBOutlet weak var atmosphereContainerView: UIView!
    @IBOutlet weak var serviceContainerView: UIView!

    // ImageViews
    @IBOutlet weak var experienceDropDownImageView: UIImageView!
    @IBOutlet weak var foodDropDownImageView: UIImageView!
    @IBOutlet weak var atmosphereDropDownImageView: UIImageView!
    @IBOutlet weak var serviceDropDownImageView: UIImageView!

    // Flame StackViews
    @IBOutlet weak var experienceFlameStackView: UIStackView!
    @IBOutlet weak var foodFlameStackView: UIStackView!
    @IBOutlet weak var atmosphereFlameStackView: UIStackView!
    @IBOutlet weak var serviceFlameStackView: UIStackView!

    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: GrowingTextView!
    @IBOutlet weak var galleryActionButton: UIButton!
    @IBOutlet weak var photoTakeActionButton: UIButton!
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    fileprivate let imagePickerController = UIImagePickerController()
    fileprivate var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImagePicker()
        navigationBarTitle = googlePlace.name
        
        scrollViewHeight.constant = 120
        commentTextView.delegate = self
    }

    // MARK: - Event Handlers

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var ratingType = ""

        if segue.identifier == "experienceSegue" {
            ratingType = ARPlaceRating.Keys.experience
        } else if segue.identifier == "foodSegue" {
            ratingType = ARPlaceRating.Keys.food
        } else if segue.identifier == "atmosphereSegue" {
            ratingType = ARPlaceRating.Keys.atmosphere
        }  else if segue.identifier == "serviceSegue" {
            ratingType = ARPlaceRating.Keys.service
        }

        if let rateButtonsContainerVC = segue.destination as? RateButtonsContainerVC {
            rateButtonsContainerVC.ratingType = ratingType
            rateButtonsContainerVC.delegate = self
        }
    }

    @IBAction func stackHeaderPressed(_ sender: UIButton) {
        if sender.restorationIdentifier == "experienceButton" {
            experienceContainerView.isHidden = !experienceContainerView.isHidden
        } else if sender.restorationIdentifier == "foodButton" {
            foodContainerView.isHidden = !foodContainerView.isHidden
        } else if sender.restorationIdentifier == "atmosphereButton" {
            atmosphereContainerView.isHidden = !atmosphereContainerView.isHidden
        } else if sender.restorationIdentifier == "serviceButton" {
            serviceContainerView.isHidden = !serviceContainerView.isHidden
        }
    }

    @IBAction func submitButtonPressed(_ sender: Any) {
        guard placeRating.atmosphere != 0, placeRating.experience != 0,
            placeRating.service != 0, placeRating.food != 0 else {
                SVProgressHUD.showError(withStatus: "Must enter a rating for each category.")
                return
        }        

        submitRating(googlePlaceId: googlePlace.placeId, rating: placeRating, comment: commentTextView.text ?? "", pictures: images, callback: { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Error submitting to rating.")
            } else {
                SVProgressHUD.showSuccess(withStatus: "Successfully Submitted!")
                NotificationCenter.default.post(name: Notification.Name(ARConstants.Notification.ACTIVITY_FEED), object: nil)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    @IBAction func galleryActionButton(_ sender: Any) {
        showImagePicker(type: .photoLibrary)
    }
    
    @IBAction func photoTakeActionButton(_ sender: Any) {
        showImagePicker(type: .camera)
    }
    
    func flameImageHelper(flamesStackView: UIStackView, rating: Float) {
        // Filling flame icons.
        let _ = flamesStackView.arrangedSubviews.enumerated().map { index, element in
            guard let flameIcon = element as? UIImageView else { return }
            let index = Float(index + 1)

            if rating >= index {
                flameIcon.image = R.image.ratingFlameFilled()
            } else if (index - rating) < 0.5 {
                flameIcon.image = R.image.ratingFlameHalf()
            } else {
                flameIcon.image = R.image.ratingFlameEmpty()
            }
        }
    }

    func hideImageViews(ratingType: ARPlaceRating.Key, rating: Float) {
        if ARPlaceRating.Keys.experience == ratingType {
            experienceFlameStackView.isHidden = false
            experienceDropDownImageView.isHidden = true
            flameImageHelper(flamesStackView: experienceFlameStackView, rating: rating)
        } else if ARPlaceRating.Keys.food == ratingType {
            foodFlameStackView.isHidden = false
            foodDropDownImageView.isHidden = true
            flameImageHelper(flamesStackView: foodFlameStackView, rating: rating)
        } else if ARPlaceRating.Keys.atmosphere == ratingType {
            atmosphereFlameStackView.isHidden = false
            atmosphereDropDownImageView.isHidden = true
            flameImageHelper(flamesStackView: atmosphereFlameStackView, rating: rating)
        } else if ARPlaceRating.Keys.service == ratingType {
            serviceFlameStackView.isHidden = false
            serviceDropDownImageView.isHidden = true
            flameImageHelper(flamesStackView: serviceFlameStackView, rating: rating)
        }
    }
}

// MARK: - Networking

extension RatePlaceViewController {
    fileprivate func setupImagePicker() {
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
    }
    
    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }
        
        imagePickerController.sourceType = type
        present(imagePickerController, animated: true, completion: nil)
    }
    
    fileprivate func submitRating(googlePlaceId: String, rating: ARPlaceRating, comment: String, pictures: [UIImage], callback:  ((Error?) -> Void)?) {
        let rateRequest = RatePlaceRequest(googlePlaceId: googlePlaceId, rating: rating, comment: comment, pictures: pictures)
        SVProgressHUD.show()
        let _ = networkSession?.send(rateRequest) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(_):
                callback?(nil)
            case .failure(let error):
                callback?(error)
            }
        }
    }
    
    fileprivate func loadImages() {
        for subview in imageScrollView.subviews {
            subview.removeFromSuperview()
        }
        if images.count != 0 {
            var imageWidth: CGFloat = imageScrollView.frame.size.width
            if images.count == 1 {
                imageWidth = imageScrollView.frame.size.width
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.moreHalfWidth
            }
            else if images.count == 2 {
                imageWidth = (imageScrollView.frame.size.width - ARConstants.ImageView.seperation) * ARConstants.ImageView.halfWidth
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.halfWidth
            }
            else {
                imageWidth = imageScrollView.frame.size.width * ARConstants.ImageView.moreHeight
                scrollViewHeight.constant = imageScrollView.frame.size.width * ARConstants.ImageView.lessHalfWidth
            }
            for i in 0..<images.count {
                let imageView = Bundle.main.loadNibNamed("ImageView", owner: self, options: nil)?.first as? ImageView
                imageView?.frame = CGRect(x: CGFloat(i) * (imageWidth + ARConstants.ImageView.seperation), y: 0, width: imageWidth, height: imageScrollView.frame.size.height)
                imageView?.setupImage(image: images[i])
                imageScrollView.addSubview(imageView!)
            }
            imageScrollView.contentSize = CGSize(width: imageWidth * CGFloat(images.count) + ARConstants.ImageView.seperation * (CGFloat(images.count) - 1), height: scrollViewHeight.constant)
        }
    }
}

// MARK: - MeetingListCardDelegate Implementation

extension RatePlaceViewController: RateButtonsContainerDelegate {
    func setRating(ratingType: ARPlaceRating.Key, rating: Float) {
        hideImageViews(ratingType: ratingType, rating: rating)
        placeRating.setRatingOnType(ratingType: ratingType, rating: rating)
    }
}

extension RatePlaceViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageTypeKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let image = info[imageTypeKey] as? UIImage {
            images.append(image)
            loadImages()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension RatePlaceViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.commentViewHeight.constant = height
        }
    }
}
