import UIKit

class SCKAlbumTableView: UITableView {
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        rowHeight = UITableViewAutomaticDimension
        separatorStyle = .none
    }
}
