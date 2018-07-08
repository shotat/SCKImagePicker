import SnapKit
import UIKit

class SCKImageCropView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
