import Foundation
import Photos

struct SCKAlbum {
    var thumbnail: UIImage?
    var title: String = ""
    var numberOfItems: Int = 0
    var collection: PHAssetCollection?
}
