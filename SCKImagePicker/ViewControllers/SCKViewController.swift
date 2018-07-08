import UIKit

private let sckAlbumViewCellId = "SCKAlbumViewCellId"

enum CurtainState: Int {
    case closed
    case closing // up to down
    case opening // down to up
    case opened // down to up
    // closed -> opening -> opened -> closing -> closed
}

class SCKViewController: UIViewController {
    var presenter: SCKPresenter!

    let topInset = CGFloat(30)
    lazy var imageCropViewHeight: CGFloat = {
        self.view.frame.width
    }()

    lazy var curtainClosedBottom: CGFloat = {
        self.imageCropViewHeight + self.imageCropView.frame.origin.y
    }()

    var curtainState: CurtainState = .closed {
        didSet {
            print(curtainState)
            switch curtainState {
            case .opened:
                UIView.animate(withDuration: 0.2) {
                    self.imageCropView.snp.updateConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-(self.imageCropViewHeight - self.topInset))
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
            case .closing:
                self.collectionView.contentOffset.y = 0
            default:
                break
            }
        }
    }

    lazy var imageCropView = SCKImageCropView()

    private var draggingBeganAt: CGFloat?

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor(red: 0xFA, green: 0xFA, blue: 0xFA, alpha: 1.0)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SCKAlbumViewCell.self, forCellWithReuseIdentifier: sckAlbumViewCellId)
        return collectionView
    }()

    lazy var collectionViewLayout: UICollectionViewLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 0
        let cellWidth = view.frame.width / 4
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        return flowLayout
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SCKPresenter()
        navigationItem.title = "SCKImagePicker"
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

        presenter.checkPhotoAuth()
        presenter.reload()
        if presenter.images.count > 0 {
            changeCropViewImage(IndexPath(item: 0, section: 0))
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

    private func changeCropViewImage(_ indexPath: IndexPath) {
        imageCropView.image = nil
        presenter.imageForCropView(indexPath: indexPath) { image in
            DispatchQueue.main.async {
                self.imageCropView.image = image
            }
        }
        // if let result = result,
        // !self.selectedAssets.contains(asset) {

        // self.selectedAssets.append(asset)
        // self.selectedImages.append(result)
        // }
    }
}

extension SCKViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeCropViewImage(indexPath)
        curtainState = .closed
    }
}

extension SCKViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return presenter.numberOfSections()
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sckAlbumViewCellId, for: indexPath) as! SCKAlbumViewCell
        // let cellWidth = view.frame.width / 3
        // let cellSize = CGSize(width: cellWidth, height: cellWidth)
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        presenter.imageForAlbumView(indexPath: indexPath) { image in
            if cell.tag == currentTag {
                cell.image = image
            }
        }

        return cell
    }
}

extension SCKViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        if pan.numberOfTouches == 0 { return }
        let location = pan.location(in: view)

        switch curtainState {
        case .closed:
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
            // change state
            if location.y < curtainClosedBottom {
                curtainState = .opening
            }
        case .opening:
            guard let draggingBeganAt = draggingBeganAt else { return }
            let offset = curtainClosedBottom - location.y
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
            }
            collectionView.contentOffset.y = draggingBeganAt
            // change state
            if location.y > curtainClosedBottom {
                curtainState = .closed
            }
        case .opened:
            let offset = imageCropViewHeight - topInset
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
            }
            if scrollView.contentOffset.y <= 0 {
                curtainState = .closing
            }
        case .closing:
            guard let draggingBeganAt = draggingBeganAt else { return }
            let offset = curtainClosedBottom - location.y + draggingBeganAt
            imageCropView.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-offset)
            }
            collectionView.contentOffset.y = 0
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        draggingBeganAt = pan.location(in: scrollView).y
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
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
