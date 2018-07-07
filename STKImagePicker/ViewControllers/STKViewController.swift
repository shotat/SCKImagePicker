import UIKit

class STKViewController: UIViewController {
    let imageCropView = STKImageCropView()
    
    let collection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageCropView)
        imageCropView.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(imageCropView.snp.width)
        }
        

        // Do any additional setup after loading the view.
    }
}
