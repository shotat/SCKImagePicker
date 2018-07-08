import Photos
import UIKit

private let stkAlbumViewCellId = "SKTAlbumViewCellId"

enum CurtainState: Int {
    case closed
    case closing // up to down
    case opening // down to up
    case opened // down to up
    // closed -> opening -> opened -> closing -> closed
}

class STKViewController: UIViewController {
    let topInset = CGFloat(40)
    var images: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager?
    var curtainState: CurtainState = .closed {
        didSet {
            print(curtainState)
            switch curtainState {
            case .opened:
                UIView.animate(withDuration: 0.2) { self.imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-(self.view.frame.width - self.topInset))
                }
                self.view.layoutIfNeeded()
                }
            case .closed:
                UIView.animate(withDuration: 0.2) {
                    self.imageCropView.snp.updateConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide)
                    }
                    self.view.layoutIfNeeded()
                }
            default:
                break
            }
        }
    }

    lazy var imageCropView = STKImageCropView()

    private var draggingStartY: CGFloat?

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(STKAlbumViewCell.self, forCellWithReuseIdentifier: stkAlbumViewCellId)
        return collectionView
    }()

    lazy var collectionViewLayout: UICollectionViewLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 0
        let cellWidth = view.frame.width / 8
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

        imageCropView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(imageCropView.snp.width)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(imageCropView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
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

        switch curtainState {
        case .closed:
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
            if location.y < imageCropView.frame.height {
                curtainState = .opening
            }
        case .opening:
            let offset = imageCropView.frame.height - location.y
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
            }
            if let startY = draggingStartY {
                collectionView.contentOffset.y = startY
            }
        case .opened:
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-(self.view.frame.width - self.topInset))
            }
            if scrollView.contentOffset.y <= 0 {
                curtainState = .closing
            }
        case .closing:
            if let startY = draggingStartY {
                collectionView.contentOffset.y = startY
                let offset = imageCropView.frame.height - location.y + startY
                imageCropView.snp.updateConstraints {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
                }
            }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        let location = pan.location(in: scrollView)
        draggingStartY = location.y
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        let pan = scrollView.panGestureRecognizer
        // let location = pan.location(in: view)
        switch curtainState {
        case .opening:
            curtainState = .opened
        case .closing:
            curtainState = .closed
        default:
            break
        }
    }
}

extension STKViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_: PHChange) {
        // TODO:
    }
}
