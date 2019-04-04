
import UIKit

class RSVPTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var meeting: ARMeeting?
    var bubble: ARBubble?
    var noResponses = [ARPerson]()


    override func viewDidLoad() {
        super.viewDidLoad()

        fillNoResponses()
    }

    func fillNoResponses() {
        guard let members = bubble?.members, let rsvps = meeting?.rsvps else { return }
        noResponses = members.filter { !rsvps.contains($0) }
    }


    // MARK: - TableView Setup

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "GOING"
        } else if section == 1 {
            return "INVITED"
        }
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, let rvspsCount = meeting?.rsvps?.count {
            return rvspsCount
        } else if section == 1 {
            return noResponses.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rsvpTableViewCell", for: indexPath) as? RSVPTableViewCell

        var person = ARPerson()

        if indexPath.section == 0 {
            person = meeting!.rsvps![indexPath.row]
        } else if indexPath.section == 1 {
            person = noResponses[indexPath.row]
        } else {
            person.firstName = "Not"
            person.lastName = "Available"
        }

        cell?.nameLabel.text = person.displayName()
        if let personImage = person.thumbnail {
            cell?.personImageView.image = personImage
        } else if let personPictureUrl = person.pictureUrl {
            cell?.personImageView.setImage(from: personPictureUrl)
        } else {
            cell?.initialsLabel.text = person.displayName(style: .abbreviated)
        }

        cell?.containerView.layer.cornerRadius = 25
        cell?.containerView.layer.masksToBounds = true

        return cell ?? UITableViewCell()
    }
}
