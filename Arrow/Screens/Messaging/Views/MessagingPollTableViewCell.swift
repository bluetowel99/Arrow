
import Foundation
import FirebaseStorage

protocol MessagingPollTableViewCellDelegate {
    func didTapOnAddOption(row:Int)
    func didTapCameraButton(row:Int)
    func didAddOption(row:Int, text: String,image: UIImage?)
    func didVoteOption(row:Int, choiceId: String)
}
class MessagingPollTableViewCell: UITableViewCell {

    @IBOutlet weak var pollContainer: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var actionButton: ARButton!
    @IBOutlet weak var shadowContainer: UIView!
    var delegate: MessagingPollTableViewCellDelegate?
    var options: [ARMessageMedia] = []
    var isAddingOption = false
    var row: Int?
    var newImage: UIImage?
    var newText: String?
    var message: ARMessage?

    var voted: Bool?
    var totalVotes: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pollContainer.layer.cornerRadius = 8.0
        self.optionsTableView.delegate = self
        self.optionsTableView.dataSource = self
        self.pollContainer.layer.borderColor = UIColor(white: 0.67, alpha: 1.0).cgColor
        self.pollContainer.layer.borderWidth = 0.5
        self.actionButton.layer.borderColor = R.color.arrowColors.waterBlue().cgColor
        self.actionButton.layer.borderWidth = 2.0
        self.actionButton.layer.cornerRadius = 2.0

        // shadow
        self.shadowContainer.layer.cornerRadius = 8.0
        self.shadowContainer.layer.shadowColor = UIColor(white: 0.67, alpha: 1.0).cgColor
        self.shadowContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.shadowContainer.layer.shadowOpacity = 0.5
        self.shadowContainer.layer.shadowRadius = 4.0

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.options = []
        self.questionLabel.text = nil
        self.optionsTableView.reloadData()
    }

    func setMessage(message: ARMessage) {
        self.message = message
        self.questionLabel.text = message.question
        self.options = message.options ?? []
        self.isAddingOption = message.isBeingEdited ?? false
        if self.isAddingOption {
            self.actionButton.setTitle("Add", for: .normal)
            self.actionButton.setTitleColor(UIColor.white, for: .normal)
            self.actionButton.backgroundColor = R.color.arrowColors.waterBlue()
            self.actionButton.disabledBackgroundColor = R.color.arrowColors.hathiGray()
            self.actionButton.isEnabled = false
        } else {
            self.actionButton.isEnabled = true
            self.actionButton.setTitle("Add Your Own Response", for: .normal)
            self.actionButton.setTitleColor(UIColor.black, for: .normal)
            self.actionButton.backgroundColor = UIColor.white
        }
        self.voted = self.checkifVoted()
        self.totalVotes = self.getTotalVotes()
        self.optionsTableView.reloadData()
    }

    func checkifVoted() -> Bool {
        let userid = ARPlatform.shared.userSession?.user?.identifier ?? "0"
        for option in self.options {
            if let votes = option.votes {
                print(votes.count)
                print(votes.keys)
                if votes[userid] != nil{
                    return true
                }
            }
        }
        return false
    }
    func getTotalVotes() -> Int {
        var total = 0
        for option in self.options {
            if let votes = option.votes {
                total += votes.keys.count
            }
        }
        return total
    }
    @IBAction func actionButtonTapped(_ sender: Any) {
        if self.isAddingOption {
            if let row = self.row, let text = self.newText {
                self.delegate?.didAddOption(row: row, text: text, image: self.message?.newImage)
            }
        } else {
            if let row = self.row {
                self.delegate?.didTapOnAddOption(row: row)
            }
        }


    }
}

extension MessagingPollTableViewCell: UITableViewDelegate {

}

extension MessagingPollTableViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isAddingOption {
            return options.count + 1
        } else {
            return options.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < options.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagingPollChoiceTableViewCell , for: indexPath)!
            cell.delegate = self
            let option = options[indexPath.row]
            if let gsurl = option.url {
                cell.choiceImageView.isHidden = false
                if let image = UIImage.cachedImage(forKey: gsurl.absoluteString) {
                    cell.choiceImageView.image = image
                } else {
                    Storage.storage().reference(forURL: gsurl.absoluteString).downloadURL(completion: {(url, error) in
                        guard let url = url else {
                            return
                        }
                        print(url.absoluteString)
                        cell.choiceImageView.setImage(from: url,key: gsurl.absoluteString, placeholder: nil,completion: nil)
                    })
                }
            } else {
                cell.choiceImageView.isHidden = true
            }
            cell.choiceTextLabel.text = option.text
            let userId = ARPlatform.shared.userSession?.user?.identifier ?? "0"
            cell.choiceButton.setImage(R.image.unasweredIcon(), for: .normal)
            if let votes = option.votes {
                if votes[userId] != nil {
                    cell.choiceButton.setImage(R.image.answeredIcon(), for: .normal)
                }
            }
            if let voted = self.voted,let votes = option.votes, let totalVotes = self.totalVotes, voted {
                cell.highlightedBackgroudWidthContraint.constant = CGFloat(votes.keys.count) / CGFloat(totalVotes) * cell.bounds.width
            } else {
                cell.highlightedBackgroudWidthContraint.constant = 0
            }
            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagingNewPollChoiceTableViewCell , for: indexPath)!
            if let message = self.message {
                if let image = message.newImage {
                    cell.pictureImageView.image = image
                    cell.cameraButton.isHidden = true
                } else {
                    cell.pictureImageView.image = nil
                    cell.cameraButton.isHidden = false
                }
            }
            cell.delegate = self
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}

extension MessagingPollTableViewCell: MessagingPollChoiceTableViewCellDelegate {
    func didSelectChoiceAtRow(row: Int) {
        if let voted = self.voted, voted {
            return
        }
        if let pollRow = self.row {
            let option = options[row]
            self.delegate?.didVoteOption(row: pollRow, choiceId: option.identifier!)
        }

    }
}

extension MessagingPollTableViewCell: MessagingNewPollChoiceTableViewCellDelegate {
    func didTapCameraButton() {
        if let row = self.row {
            self.delegate?.didTapCameraButton(row:row)
        }
    }
    func didChageText(text: String?) {
        self.newText = text
        if let text = text, !text.isEmpty {
            self.actionButton.isEnabled = true
        } else {
            self.actionButton.isEnabled = false
        }
    }
}

protocol MessagingPollChoiceTableViewCellDelegate {
    func didSelectChoiceAtRow(row: Int)
}

class MessagingPollChoiceTableViewCell : UITableViewCell {

    @IBOutlet weak var highlightedBackgroudWidthContraint: NSLayoutConstraint!
    @IBOutlet weak var choiceImageView: UIImageView!
    @IBOutlet weak var choiceTextLabel: UILabel!
    @IBOutlet weak var choiceButton: UIButton!

    var row: Int?
    var delegate: MessagingPollChoiceTableViewCellDelegate?
    @IBAction func choiceButtonTap(_ sender: Any) {
        if let row = self.row {
            self.delegate?.didSelectChoiceAtRow(row: row)
        }
    }
}

protocol MessagingNewPollChoiceTableViewCellDelegate {
    func didTapCameraButton()
    func didChageText(text: String?)
}
class MessagingNewPollChoiceTableViewCell : UITableViewCell {

    @IBOutlet weak var optionTextField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!

    var delegate: MessagingNewPollChoiceTableViewCellDelegate?
    override func awakeFromNib()  {
        super.awakeFromNib()
        optionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.didChageText(text:textField.text)
    }

    @IBAction func didTapCameraButton(_ sender: Any) {
        self.delegate?.didTapCameraButton()
    }
}
