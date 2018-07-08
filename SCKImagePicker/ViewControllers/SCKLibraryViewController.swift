import UIKit

private let sckLibraryViewCellId = "SCKLibraryViewCellId"

enum CurtainState: Int {
    // closed -> opening -> opened -> closing -> closed
    case closed
    case closing // up to down
    case opening // down to up
    case opened // down to up
}

class SCKLibraryViewController: UIViewController {
    var presenter: SCKLibraryPresenter!
    let albumsManager = SCKAlbumsManager()

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
            case .opening:
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            case .opened:
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                UIView.animate(withDuration: 0.2) {
                    self.imageCropView.snp.updateConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(-(self.imageCropViewHeight - self.topInset))
                    }
                    self.view.layoutIfNeeded()
                }
            case .closed:
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                UIView.animate(withDuration: 0.2) {
                    self.imageCropView.snp.updateConstraints {
                        $0.top.equalTo(self.view.safeAreaLayoutGuide)
                    }
                    self.view.layoutIfNeeded()
                }
            case .closing:
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.collectionView.contentOffset.y = 0
            }
        }
    }

    lazy var imageCropView = SCKImageCropView()
    private var draggingBeganAt: CGFloat?

    let collectionView: UICollectionView = SCKLibrarySelectionsView()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SCKLibraryPresenter()
        let titleView = SCKLibraryTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleView.setTitle(title: "SCKImagePicker")
        titleView.button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
        navigationItem.titleView = titleView
        navigationController?.navigationBar.isTranslucent = false

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(imageCropView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SCKLibrarySelectionsViewCell.self, forCellWithReuseIdentifier: sckLibraryViewCellId)

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

    @objc func navBarTapped() {
        let vc = SCKAlbumsViewController(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        vc.didSelectAlbum = { [weak self] _ in
            // self?.libraryVC?.setAlbum(album)
            // self?.libraryVC?.title = album.title
            // self?.libraryVC?.refreshMediaRequest()
            // self?.setTitleViewWithTitle(aTitle: album.title)
            self?.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
}

extension SCKLibraryViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeCropViewImage(indexPath)
        curtainState = .closed
    }
}

extension SCKLibraryViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return presenter.numberOfSections()
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sckLibraryViewCellId, for: indexPath) as! SCKLibrarySelectionsViewCell
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

extension SCKLibraryViewController: UIScrollViewDelegate {
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
