
import Foundation

class MessagingPollPreview: UIView {

    var view: UIView!
    var poll: ARPoll?

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var pollContainer: UIView!

    @IBOutlet weak var shadowView: UIView!
    func setPoll(poll: ARPoll) {
        self.poll = poll
        self.setupViews()
    }

    func setupViews() {
        self.optionsTableView.register(R.nib.messagingPreviewTableViewCell)
        self.questionLabel.text = poll?.question
        self.optionsTableView.dataSource = self
        self.optionsTableView.delegate = self
        self.optionsTableView.reloadData()

        // shadow
        self.pollContainer.layer.cornerRadius = 8.0
        self.shadowView.layer.cornerRadius = 8.0
        self.shadowView.layer.shadowColor = UIColor(white: 0.67, alpha: 1.0).cgColor
        self.shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.shadowView.layer.shadowOpacity = 0.5
        self.shadowView.layer.shadowRadius = 4.0

    }
    class func instanceFromNib() -> MessagingPollPreview {
        return UINib(nibName: "MessagingPollPreview", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! MessagingPollPreview
    }

}

extension MessagingPollPreview: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagingPreviewTableViewCell, for: indexPath)
        if let option = self.poll?.options?[indexPath.row] {
            if let image = option.image {
                cell?.optionImageView.isHidden = false
                cell?.optionImageView.image = image
            } else {
                cell?.optionImageView.isHidden = true
            }
            cell?.optionTextLabel.text = option.text
        }

        return cell ?? UITableViewCell()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.poll?.options?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

}

extension MessagingPollPreview: UITableViewDelegate {

}
