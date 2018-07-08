import Foundation

final class SCKAlbumsPresenter {
    let albumsManager: SCKAlbumsManager
    var albums: [SCKAlbum] = []

    init(albumsManager: SCKAlbumsManager) {
        self.albumsManager = albumsManager
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfItemsInSection(_: Int) -> Int {
        return albums.count
    }

    func fetchAlbums(completion: @escaping (() -> Void)) {
        DispatchQueue.global().async { [weak self] in
            self?.albums = self?.albumsManager.fetchAlbums() ?? []
            completion()
        }
    }
}
