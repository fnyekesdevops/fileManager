import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagePreviewView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    
    static let id: String = "image"
    
    var imagePath: URL? {
        didSet {
            setUpCell()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .yellow : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setUpCell() {
        guard let imagePath = self.imagePath else { return }
        
        imagePreviewView.image = UIImage(contentsOfFile: imagePath.path)
        imageNameLabel.text = imagePath.lastPathComponent
    }

}
