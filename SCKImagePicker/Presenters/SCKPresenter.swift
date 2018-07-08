import Photos

final class SCKPresenter: NSObject {
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        print(section)
        return images == nil ? 0 : images.count
    }

    func imageForAlbumView(indexPath: IndexPath, completion: @escaping ((UIImage?) -> Void)) {
        let asset = images[(indexPath as NSIndexPath).item]
        let cellSize = CGSize(width: 200, height: 200)
        requestImage(asset: asset, cellSize: cellSize, completion: completion)
    }

    func imageForCropView(indexPath: IndexPath, completion: @escaping ((UIImage?) -> Void)) {
        let asset = images[(indexPath as NSIndexPath).item]
        let cellSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        requestImage(asset: asset, cellSize: cellSize, completion: completion)
    }

    private func requestImage(asset: PHAsset, cellSize: CGSize, completion: @escaping ((UIImage?) -> Void)) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        imageManager?.requestImage(
            for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in completion(result) }
    }

    func reload() {
        let options = PHFetchOptions()
        // Sorting condition
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        images = PHAsset.fetchAssets(with: .image, options: options)
    }

    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
                PHPhotoLibrary.shared().register(self)
            // DispatchQueue.main.async {
            // self.delegate?.albumViewCameraRollAuthorized()
            // }
            // case .restricted, .denied:
            // DispatchQueue.main.async(execute: { () -> Void in
            // self.delegate?.albumViewCameraRollUnauthorized()
            // })
            default:
                break
            }
        }
    }
}

extension SCKPresenter: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_: PHChange) {
        /*
         DispatchQueue.main.async {
         let fetchResult = self.mediaManager.fetchResult!
         let collectionChanges = changeInstance.changeDetails(for: fetchResult)
         if collectionChanges != nil {
         self.mediaManager.fetchResult = collectionChanges!.fetchResultAfterChanges
         let collectionView = self.v.collectionView!
         if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
         collectionView.reloadData()
         } else {
         collectionView.performBatchUpdates({
         let removedIndexes = collectionChanges!.removedIndexes
         if (removedIndexes?.count ?? 0) != 0 {
         collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
         }
         let insertedIndexes = collectionChanges!.insertedIndexes
         if (insertedIndexes?.count ?? 0) != 0 {
         collectionView
         .insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
         }
         let changedIndexes = collectionChanges!.changedIndexes
         if (changedIndexes?.count ?? 0) != 0 {
         collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
         }
         }, completion: nil)
         }
         self.mediaManager.resetCachedAssets()
         }
         }
         */
    }
}
