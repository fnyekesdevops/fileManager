import UIKit

class DirectoryTableViewCell: UITableViewCell {

    static let id: String = "directory"
    
    var directoryName: String? {
        didSet {
            directoryNameLabel.text = directoryName
        }
    }
    
    @IBOutlet weak var directoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)
        
        backgroundColor = selected ? .yellow : .clear
    }
    
}
