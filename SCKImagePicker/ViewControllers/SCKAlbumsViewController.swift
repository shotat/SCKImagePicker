import UIKit

let albumsCellId = "SCKAlbumsCellId"

class SCKAlbumsViewController: UIViewController {
    var didSelectAlbum: ((SCKAlbum) -> Void)?
    let presenter: SCKAlbumsPresenter
    let albumsTableView = SCKAlbumTableView()

    required init(albumsManager: SCKAlbumsManager) {
        presenter = SCKAlbumsPresenter(albumsManager: albumsManager)
        super.init(nibName: nil, bundle: nil)
        title = "Albums"
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = cancelButton

        albumsTableView.delegate = self
        albumsTableView.dataSource = self
        albumsTableView.register(SCKAlbumsCell.self, forCellReuseIdentifier: albumsCellId)

        view.addSubview(albumsTableView)
        albumsTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        presenter.fetchAlbums {
            DispatchQueue.main.async {
                self.albumsTableView.reloadData()
            }
        }
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension SCKAlbumsViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfItemsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album = presenter.albums[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: albumsCellId, for: indexPath) as? SCKAlbumsCell else {
            return UITableViewCell()
        }
        cell.configure(album: album)
        return cell
    }
}

extension SCKAlbumsViewController: UITableViewDelegate {
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectAlbum?(presenter.albums[indexPath.row])
    }
}
