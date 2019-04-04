
import UIKit

protocol POILitMeterDelegate {
    func litMeterWillClose()
}

final class POILitMeterVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.pOILitMeter()
    static var kStoryboardIdentifier: String? = "POILitMeterVC"
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var blurredBackgroundView: UIView!
    @IBOutlet weak var cardContainerView: UIView!
    
    var litMeterDelegate: POILitMeterDelegate?
    
    private(set) var poi: ARGooglePlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupView()
    }
    
    @IBAction func CloseAction(_ sender: Any) {
        self.litMeterDelegate?.litMeterWillClose()
    }
    
    @IBAction func ThumbsUpAction(_ sender: Any) {
        print("thumbsUp")
        
        let checkInReq = PlaceLitMeterRequest(googlePlaceId: (poi?.placeId)!, litPoints: 1.0)
        let _ = networkSession?.send(checkInReq) { result in
            switch result {
            case .success:
                print("rating success")
            case .failure(let error):
                print("rating error: \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func ThumbsDownAction(_ sender: Any) {
        print("thumbsDown")
        
        let checkInReq = PlaceLitMeterRequest(googlePlaceId: (poi?.placeId)!, litPoints: -1.0)
        let _ = networkSession?.send(checkInReq) { result in
            switch result {
            case .success:
                print("rating success")
            case .failure(let error):
                print("rating error: \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setupBackground()
    {
        //view.backgroundColor = .clear
    }
    
    func setPlace(place: ARGooglePlace) {
        poi = place
    }
    
    func setupView() {
        placeName.text = poi?.name
        if let imageUrl = poi?.photos?.first?.url {
            placeImage.setImage(from: imageUrl) {
                self.placeImage.image = self.placeImage.image!.tint(tintColor: R.color.arrowColors.marineBlue())
            }
        }
        
        setupBackgroundBlur()
        cardContainerView.layer.cornerRadius = 8.0
        view.backgroundColor = .clear
    }
    
    fileprivate func setupBackgroundBlur() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredBackgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredBackgroundView.addSubview(blurEffectView)
        blurredBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CloseAction(_:))))
    }
}

extension UIImage {
    
    // colorize image with given tint color
    // this is similar to Photoshop's "Color" layer blend mode
    // this is perfect for non-greyscale source images, and images that have both highlights and shadows that should be preserved
    // white will stay white and black will stay black as the lightness of the image is preserved
    func tint(tintColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(self.cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            tintColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    // fills the alpha channel of the source image with the given color
    // any color information except to the alpha channel will be ignored
    func fillAlpha(fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            //            context.fillCGContextFillRect(context, rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(self.cgImage!, in: rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
}
