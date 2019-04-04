
import UIKit
import GoogleMaps

protocol MessagesLocationSharingSearchTableDelegate {
    func didSelectPlace(place: ARGooglePlace)
}
final class MessagesLocationSharingSearchTableVC: UITableViewController, StoryboardViewController {

    static var kStoryboard: UIStoryboard = R.storyboard.messagesLocationSharingSearchTable()
    static var kStoryboardIdentifier: String? = "MessagesLocationSharingSearchTableVC"

    fileprivate var placemarks = [ARGooglePlace]()
    var delegate : MessagesLocationSharingSearchTableDelegate?
    func setPlacemarks(placemarks: [ARGooglePlace]?) {
        self.placemarks = placemarks ?? []
        self.tableView.reloadData()
    }

}

extension MessagesLocationSharingSearchTableVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placemarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MessagesLocationShareCell?
        cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.messagesLocationShareCell, for: indexPath)
        let placemark = placemarks[indexPath.row]
        cell?.locationAddressShareLabel.text = placemark.address
        cell?.locationShareLabel.text = placemark.name

        return cell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectPlace(place: self.placemarks [indexPath.row])
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}
