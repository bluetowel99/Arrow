
import Foundation
import GrowingTextView

protocol CommentSectionHeaderDelegate {
    func galleryButtonPressed()
    func photoTakeButtonPressed()
    func sendButonPressed(commentTextView: UITextView)
    func sendMessage(message: String)
}

final class CommentSectionHeader: UITableViewHeaderFooterView, UITextFieldDelegate {
    
    static var reuseIdentifier: String {
        return "CommentSectionHeader"
    }
    
    static var height: CGFloat = 85.0
    var delegate: CommentSectionHeaderDelegate?
    
    @IBOutlet weak var commentTextView: GrowingTextView!
    @IBOutlet weak var sendActionButton: UIButton!
    @IBOutlet weak var galleryActionButton: UIButton!
    @IBOutlet weak var photoTakeActionButton: UIButton!
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    
    func setupHeader(message: String?) {
        contentView.backgroundColor = .white
        commentTextView.delegate = self
        
        commentTextView.text = message
    }
    
    @IBAction func sendActionButton(_ sender: Any) {
        commentTextView.resignFirstResponder()
        delegate?.sendButonPressed(commentTextView: commentTextView)
    }
    
    @IBAction func galleryActionButton(_ sender: Any) {
        delegate?.galleryButtonPressed()
    }
    
    @IBAction func photoTakeActionButton(_ sender: Any) {
        delegate?.photoTakeButtonPressed()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension CommentSectionHeader: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.commentViewHeight.constant = height
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.sendMessage(message: textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.sendMessage(message: textView.text)
    }
}
