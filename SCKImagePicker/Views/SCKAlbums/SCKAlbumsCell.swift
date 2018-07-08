import UIKit

class SCKAlbumsCell: UITableViewCell {
    let thumbnail: UIImageView = {
        let thumbnail = UIImageView()
        thumbnail.backgroundColor = .gray
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        return thumbnail
    }()

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        return label
    }()

    let numberOfItems: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(thumbnail)
        addSubview(title)
        addSubview(numberOfItems)
        thumbnail.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview().inset(6)
            $0.height.equalTo(70)
            $0.width.equalTo(thumbnail.snp.height)
        }

        title.snp.makeConstraints {
            $0.top.equalToSuperview().inset(6)
            $0.left.equalTo(thumbnail.snp.right).offset(6)
        }

        numberOfItems.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(10)
            $0.left.equalTo(thumbnail.snp.right).offset(6)
        }
    }

    func configure(album: SCKAlbum) {
        thumbnail.image = album.thumbnail
        title.text = album.title
        numberOfItems.text = "\(album.numberOfItems)"
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
