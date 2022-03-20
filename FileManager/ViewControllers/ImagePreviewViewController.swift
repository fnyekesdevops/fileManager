import UIKit

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        setUpImageView()
    }

    private func setUpImageView() {
        guard let imagePath = self.imagePath else { return }
        
        imageView.image = UIImage(contentsOfFile: imagePath.path)
    }

}

extension ImagePreviewViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
