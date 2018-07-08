import Photos
import UIKit

private let stkAlbumViewCellId = "SKTAlbumViewCellId"

class STKViewController: UIViewController {
    let topInset = CGFloat(40)
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?
    var isExpanding: Bool = false
    lazy var imageCropView = STKImageCropView()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: view.frame.width, left: 0, bottom: 0, right: 0)
        collectionView.register(STKAlbumViewCell.self, forCellWithReuseIdentifier: stkAlbumViewCellId)
        return collectionView
    }()

    lazy var collectionViewLayout: UICollectionViewLayout = {
        let flowLayout = STKAlbumViewLayout(minimumHeight: self.view.frame.height - topInset)
        let margin: CGFloat = 0
        let cellWidth = view.frame.width / 4
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        return flowLayout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(imageCropView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageCropView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(imageCropView.snp.width)
        }

        checkPhotoAuth()
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false),
        ]
        images = PHAsset.fetchAssets(with: .image, options: options)
        if images.count > 0 {
            // changeImage(images[0])
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
        PHPhotoLibrary.shared().register(self)
    }

    // Check the status of authorization for PHPhotoLibrary
    func checkPhotoAuth() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
            // if let images = self.images, images.count > 0 {
            // self.changeImage(images[0])
            // }
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

extension STKViewController: UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return images == nil ? 0 : images.count
    }
}

extension STKViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: stkAlbumViewCellId, for: indexPath) as! STKAlbumViewCell
        let cellWidth = view.frame.width / 3
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        let currentTag = cell.tag + 1
        cell.tag = currentTag

        let asset = images[(indexPath as NSIndexPath).item]
        imageManager?.requestImage(for: asset,
                                   targetSize: cellSize,
                                   contentMode: .aspectFill,
                                   options: nil) {
            result, _ in

            if cell.tag == currentTag {
                cell.image = result
            }
        }
        return cell
    }
}

extension STKViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        if pan.numberOfTouches == 0 {
            return
        }
        let location = pan.location(in: view)
        if isExpanding {
            if scrollView.contentOffset.y < -topInset {
                let offset = view.frame.width + collectionView.contentOffset.y
                // collectionView.contentInset = UIEdgeInsets(top: location.y, left: 0, bottom: 0, right: 0)
                imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
                }
            }
        } else {
            if location.y < imageCropView.frame.height {
                let offset = imageCropView.frame.height - location.y
                collectionView.contentInset = UIEdgeInsets(top: location.y, left: 0, bottom: 0, right: 0)
                imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
                }
            } else {
                // collectionView.contentInset = UIEdgeInsets(top: view.frame.width, left: 0, bottom: 0, right: 0)
                imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide)
                }
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let pan = scrollView.panGestureRecognizer
        let location = pan.location(in: view)
        if isExpanding {
            isExpanding = false
            UIView.animate(withDuration: 0.2) {
                self.collectionView.contentInset = UIEdgeInsets(top: self.view.frame.width, left: 0, bottom: 0, right: 0)
                self.imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide)
                }
                self.view.layoutIfNeeded()
            }
        } else {
            if location.y < view.frame.width {
                isExpanding = true
                UIView.animate(withDuration: 0.2) {
                    self.collectionView.contentInset = UIEdgeInsets(top: self.topInset, left: 0, bottom: 0, right: 0)
                    self.imageCropView.snp.updateConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-(self.view.frame.width - self.topInset))
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension STKViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_: PHChange) {
        // TODO:
    }
}
