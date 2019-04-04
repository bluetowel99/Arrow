
import Foundation

protocol ImageViewDelegate {
    func openImage(imageUrl: URL?)
}

final class ImageView: UIView {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIImageView!
    
    fileprivate(set) var imageUrl: URL?
    var delegate: ImageViewDelegate?
    
    func setupView(imageUrl: URL?) -> Void {
        self.imageUrl = imageUrl
        
        loadImage()
    }
    
    func setupImage(image: UIImage?) -> Void {
        self.thumbnailImageView.image = image
        self.activityIndicator.isHidden = true
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGesture:)))
//        self.thumbnailImageView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func loadImage() {
        // Set image.
        if let imageUrl = imageUrl {
            activityIndicator.startInfiniteRotationAnimation()
            activityIndicator.isHidden = false
            thumbnailImageView.setImage(from: imageUrl) {
                self.activityIndicator.stopInfiniteRotationAnimation()
                self.activityIndicator.isHidden = true
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped(tapGesture:)))
                self.thumbnailImageView.addGestureRecognizer(tapGesture)
            }
        }        
    }
    
    @objc func imageTapped(tapGesture: UITapGestureRecognizer) {
        delegate?.openImage(imageUrl: imageUrl)
    }
}
