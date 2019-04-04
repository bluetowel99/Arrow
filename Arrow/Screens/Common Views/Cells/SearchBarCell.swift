
import UIKit

class SearchBarCell: UITableViewCell {
    
    static var rowHeight: CGFloat = 64.0
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
            textField.addTarget(self, action: #selector(searchTextFieldChanged(_:)), for: .editingChanged)
        }
    }
    
    var delegate: SearchBarCellDelegate?
    
    func setup(icon: UIImage? = nil, placeholderText: String? = nil, searchText: String? = nil, inputAccessoryView: UIView? = nil) {
        selectionStyle = .none
        iconImageView.image = icon
        textField.placeholder = placeholderText
        textField.inputAccessoryView = inputAccessoryView
        textField.text = searchText
        if let _ = searchText {
            textField.becomeFirstResponder()
        }
    }
    
    override func prepareForReuse() {
        iconImageView.image = nil
        textField.text = nil
        textField.placeholder = nil
        textField.inputAccessoryView = nil
    }
    
}

// MARK: - Event Handlers

extension SearchBarCell {
    
    @objc func searchTextFieldChanged(_ textField: UITextField) {
        delegate?.searchBarCell(searchBarCell: self, textDidChange: textField.text)
    }
    
}

// MARK: - UITextFieldDelegate

extension SearchBarCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - SearchBarCellDelegate Definition

protocol SearchBarCellDelegate {
    func searchBarCell(searchBarCell: SearchBarCell, textDidChange text: String?)
}
