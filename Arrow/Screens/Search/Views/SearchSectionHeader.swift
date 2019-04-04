
import UIKit

final class SearchSectionHeader: UITableViewHeaderFooterView {
    
    static var reuseIdentifier: String {
        return "SearchSectionHeader"
    }
    
    static var height: CGFloat = 40.0

    @IBOutlet weak var titleLabel: UILabel!
    
    func setupHeader(title: String) {
        contentView.backgroundColor = .white
        titleLabel.text = title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }    
}
