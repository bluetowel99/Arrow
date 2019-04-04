
import UIKit

final class SimpleSectionHeader: UITableViewHeaderFooterView {
    
    static var reuseIdentifier: String {
        return "SimpleSectionHeader"
    }
    
    static var height: CGFloat = 30.0

    @IBOutlet weak var titleLabel: UILabel!
    
    func setupHeader(title: String) {
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
}
