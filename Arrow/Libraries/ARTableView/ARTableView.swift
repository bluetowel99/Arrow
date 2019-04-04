
import UIKit

final class ARTableView: UITableView {
    
    @IBInspectable var displaysFixedTableHeaderView: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard displaysFixedTableHeaderView else { return }
        tableHeaderView?.frame.origin.y = contentOffset.y
    }
    
}
