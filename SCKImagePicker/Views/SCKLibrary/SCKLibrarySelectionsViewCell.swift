import UIKit

class SCKLibrarySelectionsViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let selectionOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.alpha = 0
        return v
    }()

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
        addSubview(selectionOverlay)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        selectionOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override var isSelected: Bool {
        didSet { isHighlighted = isSelected }
    }

    override var isHighlighted: Bool {
        didSet {
            selectionOverlay.alpha = isHighlighted ? 0.4 : 0
        }
    }
}
