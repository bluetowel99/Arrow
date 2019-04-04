
import Photos
import UIKit

class MessagesGallerySharingCollectionVC: UICollectionViewController {
    
    var selectionChanged: (()->Void?)?
    
    fileprivate var fetchResult: PHFetchResult<PHAsset>!
    fileprivate let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.allowsMultipleSelection = true
        setupFetchResult()
        PHPhotoLibrary.shared().register(self)
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let columnCount: CGFloat = 3
        let cellSpacing = flowLayout.minimumInteritemSpacing
        let cellWidth = (view.frame.width - (cellSpacing * (columnCount + 1))) / columnCount
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.itemSize = cellSize
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setupFetchResult() {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)


        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: options)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessagesGallerySharingCell", for: indexPath) as? MessagesGallerySharingCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        
        let asset = fetchResult.object(at: indexPath.item)
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: cell.bounds.size, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in

            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
        
    }

    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        handleSelectionChange()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelectionChange()
    }
    
    func handleSelectionChange() {
        guard let selectionChanged = self.selectionChanged else { return }
        selectionChanged()
    }
    
    func deselect() {
        guard let collectionView = self.collectionView,
        let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems else { return }
        
        for indexPath in indexPathsForSelectedItems {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        handleSelectionChange()
    }

    func getSelectedImages() -> [ARMediaInputData] {
        guard let collectionView = self.collectionView,
            let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems else {  return [] }
        var assets: [PHAsset] = []
        for indexPath in indexPathsForSelectedItems {
            assets.append(fetchResult.object(at: indexPath.item))
        }
        var images: [ARMediaInputData] = []
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        for asset in assets {
            manager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let image = result {
                    images.append(ARMediaInputData(type: .image, image: image, movieUrl: nil))
                }
            })
        }
        return images
    }
}
 

// MARK: - PHPhotoLibraryChangeObserver

extension MessagesGallerySharingCollectionVC: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                fetchResult = changeDetails.fetchResultAfterChanges
                collectionView?.reloadData()
            }
            
        }
    }
    
}
