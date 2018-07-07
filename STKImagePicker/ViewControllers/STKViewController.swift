import UIKit

class STKViewController: UIViewController {
    lazy var imageCropView = STKImageCropView()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        // collectionView.contentInset = UIEdgeInsets(top: view.frame.width, left: 0, bottom: 0, right: 0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    lazy var collectionViewLayout: UICollectionViewLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 0
        flowLayout.itemSize = CGSize(width: 100.0, height: 100.0)
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
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(imageCropView.snp.width)
        }
    }
}

extension STKViewController: UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 20
    }
}

extension STKViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .cyan
        return cell
    }
}

extension STKViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pan = scrollView.panGestureRecognizer
        let location = pan.location(in: view)
        if location.y < imageCropView.frame.height {
            let offset = imageCropView.frame.height - location.y
            collectionView.contentInset = UIEdgeInsets(top: location.y, left: 0, bottom: 0, right: 0)
            imageCropView.snp.updateConstraints {
                $0.top.equalToSuperview().offset(-offset)
            }
        } else {
            collectionView.contentInset = UIEdgeInsets(top: view.frame.width, left: 0, bottom: 0, right: 0)
            imageCropView.snp.updateConstraints {
                $0.top.equalToSuperview()
            }
        }
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        UIView.animate(withDuration: 0.2) {
            // self.collectionView.contentInset = UIEdgeInsets(top: self.view.frame.width, left: 0, bottom: 0, right: 0)
            self.imageCropView.snp.updateConstraints {
                $0.top.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
}
