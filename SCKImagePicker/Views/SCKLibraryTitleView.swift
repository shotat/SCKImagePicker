import UIKit

class SCKLibraryTitleView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        if let navBarTitleFont = UINavigationBar.appearance().titleTextAttributes?[.font] as? UIFont {
            label.font = navBarTitleFont
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 17)
        }

        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            label.textColor = navBarTitleColor
        }

        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        return button
    }()

    func setTitle(title: String) {
        titleLabel.text = title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // let arrow = UIImageView()
        // arrow.image = YPConfig.icons.arrowDownIcon
        // button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(button)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
