import UIKit

class DirectoryCollectionViewCell: UICollectionViewCell {

    static let id: String = "directory"
    
    @IBOutlet weak var directoryNameLabel: UILabel!
    
    var directoryName: String? {
        didSet {
            directoryNameLabel.text = directoryName
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .yellow : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
