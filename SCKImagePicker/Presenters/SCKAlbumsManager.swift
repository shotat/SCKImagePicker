import Foundation
import Photos

class SCKAlbumsManager {
    private static let instance = SCKAlbumsManager()
    class var sharedDefault: SCKAlbumsManager {
        return instance
    }

    private var cachedAlbums: [SCKAlbum]?

    func fetchAlbums() -> [SCKAlbum] {
        if let cachedAlbums = cachedAlbums { return cachedAlbums }
        var albums = [SCKAlbum]()
        let options = PHFetchOptions()

        let smartAlbumsResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                        subtype: .any,
                                                                        options: options)
        let albumsResult = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                   subtype: .any,
                                                                   options: options)
        for result in [smartAlbumsResult, albumsResult] {
            result.enumerateObjects({ assetCollection, _, _ in
                var album = SCKAlbum()
                album.title = assetCollection.localizedTitle ?? ""
                album.numberOfItems = self.mediaCountFor(collection: assetCollection)
                if album.numberOfItems > 0 {
                    let r = PHAsset.fetchKeyAssets(in: assetCollection, options: nil)
                    if let first = r?.firstObject {
                        let targetSize = CGSize(width: 78 * 2, height: 78 * 2)
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .fastFormat
                        PHImageManager.default().requestImage(for: first,
                                                              targetSize: targetSize,
                                                              contentMode: .aspectFit,
                                                              options: options,
                                                              resultHandler: { image, _ in
                                                                  album.thumbnail = image
                        })
                    }
                    album.collection = assetCollection

                    if !(assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos
                        || assetCollection.assetCollectionSubtype == .smartAlbumVideos) {
                        albums.append(album)
                    }
                }
            })
        }
        cachedAlbums = albums
        return albums
    }

    func mediaCountFor(collection: PHAssetCollection) -> Int {
        let options = PHFetchOptions()
        let photoPredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.predicate = photoPredicate
        let result = PHAsset.fetchAssets(in: collection, options: options)
        return result.count
    }
}
