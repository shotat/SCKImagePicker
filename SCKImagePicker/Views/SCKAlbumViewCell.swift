import UIKit

class SCKAlbumViewCell: UICollectionViewCell {
    let imageView: UIImageView = UIImageView()
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
