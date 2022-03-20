import UIKit

class ImageTableViewCell: UITableViewCell {

    static let id: String = "image"
    
    @IBOutlet weak var imagePreviewView: UIImageView!
    @IBOutlet weak var imageNameLabel: UILabel!
    
    var imagePath: URL? {
        didSet {
            setUpCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        backgroundColor = selected ? .yellow : .clear
    }
    
    private func setUpCell() {
        guard let imagePath = self.imagePath else { return }
        
        imagePreviewView.image = UIImage(contentsOfFile: imagePath.path)
        imageNameLabel.text = imagePath.lastPathComponent
    }
    
}
