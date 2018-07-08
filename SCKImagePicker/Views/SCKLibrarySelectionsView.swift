import UIKit

class SCKLibrarySelectionsView: UICollectionView {
    init() {
        super.init(frame: .zero, collectionViewLayout: SCKLibrarySelectionsLayout())
        backgroundColor = UIColor(red: 0xFA, green: 0xFA, blue: 0xFA, alpha: 1.0)
        alwaysBounceVertical = true
        allowsMultipleSelection = true
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}

class SCKLibrarySelectionsLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        let window = UIWindow(frame: UIScreen.main.bounds)
        let cellWidth = window.frame.width / 4
        let margin = CGFloat(0)

        itemSize = CGSize(width: cellWidth, height: cellWidth)
        minimumInteritemSpacing = margin
        minimumLineSpacing = margin
    }

    required init?(coder _: NSCoder) {
        fatalError()
    }
}
