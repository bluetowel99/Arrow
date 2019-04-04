
import UIKit

protocol MessagesGallerySharingProtocol {
    func messagesGallerySharingDidCancel()
    func messagesGallerySharingComplete(images: [ARMediaInputData])
}

final class MessagesGallerySharingVC: ARDrawerContentViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.messagesGallerySharing()
    static var kStoryboardIdentifier: String? = "MessagesGallerySharingVC"
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var selectedCountLabel: UILabel!
    @IBOutlet weak var toolsContainerView: MessagesSharingToolsContainer!
    var delegate: MessagesGallerySharingProtocol?
    
    var collectionViewController: MessagesGallerySharingCollectionVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateToolsContainer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CollectionViewSegue" {
            guard let collectionVC = segue.destination as? MessagesGallerySharingCollectionVC else { return }
            
            collectionVC.selectionChanged = {
                self.updateToolsContainer()
            }
            
            collectionViewController = collectionVC
        }
    }
    
    
    @IBAction func deselect(_ sender: Any) {
        guard let collectionVC = collectionViewController else { return }
        collectionVC.deselect()
    }
    
    @IBAction func add(_ sender: Any) {
        guard let collectionVC = collectionViewController else { return }
        let images = collectionVC.getSelectedImages()

        self.delegate?.messagesGallerySharingComplete(images: images)
        dismiss()
    }

}

// MARK: - UI Helpers 

extension MessagesGallerySharingVC {
    
    func updateToolsContainer() {
        guard let collectionVC = collectionViewController,
            let collectionView = collectionVC.collectionView else {
                toolsContainerView.isHidden = true
                return
        }
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.count > 0 {
                self.selectedCountLabel.text = "\(selectedItems.count) selected"
                showToolsContainer()
            } else {
                hideToolsContainer()
            }
        } else {
            hideToolsContainer()
        }
    }
    
    func showToolsContainer() {
        if toolsContainerView.isHidden {
            UIView.animate(withDuration: 0.2) {
                self.toolsContainerView.isHidden = false
                self.stackView.layoutIfNeeded()
            }
        }
    }
    
    func hideToolsContainer() {
        if !toolsContainerView.isHidden {
            UIView.animate(withDuration: 0.2) {
                self.toolsContainerView.isHidden = true
                self.stackView.layoutIfNeeded()
            }
        }
    }

}

class MessagesSharingToolsContainer: UIView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 40)
    }
    
}
