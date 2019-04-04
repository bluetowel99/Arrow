
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

final class MessagesTableVC: UITableViewController, StoryboardViewController {
	
    static var kStoryboard: UIStoryboard = R.storyboard.messagesTable()
    static var kStoryboardIdentifier: String? = "MessagesTableVC"

    var threadId: String?
    var thread: ARMessageThread?
    fileprivate lazy var messagesRef: DatabaseReference = Database.database().reference().child("messages")
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://arrow-8ed70.appspot.com")

    fileprivate let imageURLNotSetKey = "NOTSET"
    fileprivate var newMessageRefHandle: DatabaseHandle?
    fileprivate var newMessageUpdateHandle: DatabaseHandle?

    fileprivate var messages: [ARMessage] = []
    fileprivate var mediaMessageMap = [String: Int]()

    fileprivate var imagePickerController: UIImagePickerController?
    fileprivate var choosePictureMenu: UIAlertController?

    var selectedRow: Int?
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Delay initializations for performant view appearance.
        if imagePickerController == nil {
            imagePickerController = UIImagePickerController()
            setupImagePicker()
        }

        if choosePictureMenu == nil {
            choosePictureMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            setupChoosePictureMenu()
        }
    }



    @IBOutlet var accessoryView: MessagingInputAccessoryView! {
        didSet {
            accessoryView.viewContoller = self
            accessoryView.delegate = self
        }
    }

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    var inputAccessoryVC: UIInputViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeMessages()
        accessoryView.messageThreadType = .bubble
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.title = self.thread?.title
    }



    override var inputAccessoryView: UIView? {
        return accessoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    private func setupChoosePictureMenu() {
        let photoLibraryItem = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.showImagePicker(type: .photoLibrary)
        }
        choosePictureMenu?.addAction(photoLibraryItem)
        let cameraItem = UIAlertAction(title: "Take Photo", style: .default) { action in
            self.showImagePicker(type: .camera)
        }
        choosePictureMenu?.addAction(cameraItem)
        let cancelItem = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        choosePictureMenu?.addAction(cancelItem)
    }

    private func setupImagePicker() {
        imagePickerController?.allowsEditing = true
        imagePickerController?.delegate = self
    }

    fileprivate func showImagePicker(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            print("Image picker source type \(type.rawValue) not available.")
            return
        }

        imagePickerController?.sourceType = type
        if let imagePickerController = self.imagePickerController {
            present(imagePickerController, animated: true, completion: nil)
        }
    }

}

extension MessagesTableVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            if let selectedRow = self.selectedRow, self.messages.count >= selectedRow {
                self.messages[selectedRow].newImage = image
                self.messages[selectedRow].isBeingEdited = true
            }
        }
        dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
    
}

extension  MessagesTableVC: UINavigationControllerDelegate {

}

extension MessagesTableVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textViewHeightConstraint.constant = newFrame.height
        accessoryView.layoutIfNeeded()
    }
    
}


extension MessagesTableVC {

    fileprivate func observeMessages() {
        guard let threadId = self.threadId else {
            return
        }
        
        let threadRef = messagesRef.child(threadId)
        let messageQuery = threadRef.queryLimited(toLast:999)

        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            if let text = messageData["text"] as? String, let _ = messageData["senderId"] as? String, let _ = messageData["displayName"] as? String, let typeString = messageData["type"] as? String, let _ = ARMessageType(rawValue: typeString), !text.isEmpty {
                if let message = ARMessage(with: messageData) {
                    if let _ = self.mediaMessageMap[snapshot.key] {
                        return
                    }
                    self.mediaMessageMap[snapshot.key] = self.messages.count
                    //append message
                    self.messages.append(message)
                    self.tableView.reloadData()
                    //scroll to bottom
                    if self.messages.count > 1 {
                        let lastIndex = IndexPath(row: 1, section: self.messages.count-1)
                        self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                    }
                }

            }
        })

        newMessageUpdateHandle = messageQuery.observe(.childChanged, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, AnyObject>
            if let _ = messageData["text"] as? String, let _ = messageData["senderId"] as? String, let _ = messageData["displayName"] as? String, let typeString = messageData["type"] as? String, let _ = ARMessageType(rawValue: typeString) {
                if let message = ARMessage(with: messageData){
                    if let oldMessageIndex = self.mediaMessageMap[snapshot.key] {
                        self.messages[oldMessageIndex] = message
                        self.tableView.reloadData()
                    }
                }
            }
        })


    }

}

extension MessagesTableVC {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.section]
        if indexPath.row == 1 {
            switch message.type {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingTextTableViewCell") as! MessagingTextTableViewCell
                cell.textBodyLabel.text = message.text
                return cell
            case .media:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingMediaTableViewCell") as! MessagingMediaTableViewCell
                cell.message = message
                cell.delegate = self
                return cell
            case .poll:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingPollTableViewCell") as! MessagingPollTableViewCell
                cell.row = indexPath.section
                cell.setMessage(message: message)
                cell.delegate = self
                return cell
            case .location:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingLocationTableViewCell") as! MessagingLocationTableViewCell
                cell.placeNameLabel.text = message.text
                cell.placeAddressLabel.text = message.placeAddress
                if let lat = message.lat, let lng = message.lng {
                    cell.setLocation(lat: lat, lng: lng)
                }
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingAudioTableViewCell") as! MessagingAudioTableViewCell
                cell.message = message
                cell.row = indexPath.row
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessagingHeaderTableViewCell") as! MessagingHeaderTableViewCell
            cell.message = message
            cell.delegate = self
            cell.row = indexPath.section
            cell.usernameLabel.text = message.displayName
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.messages[indexPath.section]
        if indexPath.row == 1 {
            switch message.type {
            case .poll:
                let options = message.options ?? []
                let baseHeight = 5.0 + 63.0 + 51.0
                if let isBeingEdited = message.isBeingEdited, isBeingEdited {
                    return CGFloat(baseHeight + 48.0*Double(options.count + 1))
                } else {
                     return CGFloat(baseHeight + 48.0*Double(options.count))
                }
            case .location:
                return 115
            case .audio:
                return 40
            default:
                return UITableViewAutomaticDimension
            }

        }
        return 46
        
    }
}

extension MessagesTableVC: MessagingInputAccessoryViewDelegate {
    func willSendLocation(place: ARGooglePlace) {
        let platform = ARPlatform.shared
        let userName = platform.userSession?.user?.displayName() ?? "username"
        let userId = platform.userSession?.user?.identifier ?? "1"
        let itemRef = messagesRef.child(self.threadId!).childByAutoId()
        let messageItem: [String : Any?] = [
            "identifier": itemRef.key,
            "type": ARMessageType.location.rawValue,
            "senderId": userId,
            "displayName": userName,
            "text": place.name,
            "address": place.address,
            "lat": place.latitude,
            "lng": place.longitude,
            "timestamp": ServerValue.timestamp()
            ]
        itemRef.setValue(messageItem.nilsRemoved())
    }

    func willSendMediaMessage(mediaList: [ARMediaInputData]) {
        if let key = self.sendMediaMessage(mediaList: mediaList) {
            for media in mediaList {
                self.uploadMedia(media: media, key: key)
            }
        }
    }

    func willSendPollMessage(poll: ARPoll) {
        if let key = sendPollMessage(poll: poll), let options = poll.options {
            for option in options {
                self.uploadMedia(pollOption: option, key: key)
            }
        }
    }

    func willSendAudio(audioUrl: URL) {
        if let key = sendAudioMessage() {
            self.uploadMedia(audioUrl: audioUrl, key: key)
        }
    }

    func sendPollMessage(poll: ARPoll) -> String?{
        let platform = ARPlatform.shared
        let userName = platform.userSession?.user?.displayName() ?? "username"
        let userId = platform.userSession?.user?.identifier ?? "1"
        let itemRef = messagesRef.child(self.threadId!).childByAutoId()

        let messageItem = [
            "identifier": itemRef.key,
            "type": ARMessageType.poll.rawValue,
            "senderId": userId,
            "displayName": userName,
            "text": "placeholder",
            "question": poll.question ?? "NO QUESTION",
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        itemRef.setValue(messageItem)
        if let options = poll.options {
            for option in options {
                itemRef.child("options").child(option.identifier!).setValue(["identifier": option.identifier!,"text": (option.text ?? "NO OPTION"),"type":ARMessageMediaType.option.rawValue ])
            }
        }


        return itemRef.key
    }

    func willSendTextMessage(text: String) {
        let platform = ARPlatform.shared
        let userName = platform.userSession?.user?.displayName() ?? "username"
        let userId = platform.userSession?.user?.identifier ?? "1"
        let itemRef = messagesRef.child(self.threadId!).childByAutoId()
        let messageItem = [
            "identifier": itemRef.key,
            "type": ARMessageType.text.rawValue,
            "senderId": userId,
            "displayName": userName,
            "text": text,
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        itemRef.setValue(messageItem)
    }

    func sendMediaMessage(mediaList: [ARMediaInputData]) -> String? {
        let platform = ARPlatform.shared
        let userName = platform.userSession?.user?.displayName() ?? "username"
        let userId = platform.userSession?.user?.identifier ?? "1"
        let itemRef = messagesRef.child(self.threadId!).childByAutoId()

        let messageItem = [
            "identifier": itemRef.key,
            "type": ARMessageType.media.rawValue,
            "senderId": userId,
            "displayName": userName,
            "text": "placeholder",
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        itemRef.setValue(messageItem)
        for media in mediaList {
            itemRef.child("media").child(media.identifier).setValue(["type": media.type.rawValue])
            if let placename =  media.placeName {
                itemRef.child("media").child(media.identifier).updateChildValues(["placeName":placename])
            }
            if let address =  media.address {
                itemRef.child("media").child(media.identifier).updateChildValues(["address":address])
            }

        }

        return itemRef.key
    }

    func sendAudioMessage() -> String? {
        let platform = ARPlatform.shared
        let userName = platform.userSession?.user?.displayName() ?? "username"
        let userId = platform.userSession?.user?.identifier ?? "1"
        let itemRef = messagesRef.child(self.threadId!).childByAutoId()

        let messageItem = [
            "identifier": itemRef.key,
            "type": ARMessageType.audio.rawValue,
            "senderId": userId,
            "displayName": userName,
            "text": "placeholder",
            "timestamp": ServerValue.timestamp()
            ] as [String : Any]
        itemRef.setValue(messageItem)
        return itemRef.key
    }

    func uploadMedia(media:ARMediaInputData, key:String) {
        guard let firebaseUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let path = "\(firebaseUserId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)))"
        switch media.type {
        case .image:
            if let image = media.image, let imageData = UIImageJPEGRepresentation(image.resizeImage(targetSize:  CGSize(width: 400, height: 400)), 1.0) {
                self.storageRef.child(path).putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error.localizedDescription)")
                        return
                    }

                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, mediaKey: media.identifier  ,forMessageWithKey: key)
                }
            }
            break
        default:
            break
        }
    }

    func uploadMedia(pollOption:ARPollOption, key:String) {
        guard let firebaseUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let path = "\(firebaseUserId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)))"
        if let image = pollOption.image, let imageData = UIImageJPEGRepresentation(image.resizeImage(targetSize:  CGSize(width: 200, height: 200)), 1.0) {
            self.storageRef.child(path).putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading photo: \(error.localizedDescription)")
                    return
                }

                self.setImageURL(self.storageRef.child((metadata?.path)!).description, optionkey: pollOption.identifier!  ,forMessageWithKey: key)
            }
        }

    }

    func uploadMedia(audioUrl:URL, key:String) {
        guard let firebaseUserId = Auth.auth().currentUser?.uid else {
            return
        }
        let path = "\(firebaseUserId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)))"
        self.storageRef.child(path).putFile(from: audioUrl, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading audio: \(error.localizedDescription)")
                return
            }
            self.setAudioURL(self.storageRef.child((metadata?.path)!).description ,forMessageWithKey: key)
        }
    }

    func setImageURL(_ url: String, mediaKey: String ,forMessageWithKey key: String) {
        let itemRef = messagesRef.child(self.threadId!).child(key).child("media")
        let newUrl = itemRef.child(mediaKey)
        newUrl.updateChildValues(["url": url])
    }

    func setImageURL(_ url: String, optionkey:String ,forMessageWithKey key: String) {
        let itemRef = messagesRef.child(self.threadId!).child(key).child("options")
        let newUrl = itemRef.child(optionkey)
        newUrl.updateChildValues(["url": url])
    }
    func setAudioURL(_ url: String ,forMessageWithKey key: String) {
        let itemRef = messagesRef.child(self.threadId!).child(key)
        itemRef.updateChildValues(["audioUrl": url])
    }
}
extension MessagesTableVC: MessagingMediaTableViewCellDelegate {

    func didTapMedia(message: ARMessage, index: Int?) {
        let details = MessagesMediaDetailsVC.instantiate()
        details.mediaIndex = index
        details.message = message
        self.present(details, animated: true, completion: nil)
    }
}
extension MessagesTableVC: MessagingHeaderTableViewCellDelegate {

    func didlikeMessage(row: Int) {
        if let userId = ARPlatform.shared.userSession?.user?.identifier {
            let indentifier = self.messages[row].identifier
            messagesRef.child(self.threadId!).child(indentifier!).child("likes").updateChildValues(["\(userId)": true])
        }
    }
}
extension MessagesTableVC: MessagingPollTableViewCellDelegate {

    func didVoteOption(row:Int, choiceId: String) {
        let userId = ARPlatform.shared.userSession?.user?.identifier ?? "1"
        let indentifier = self.messages[row].identifier
        messagesRef.child(self.threadId!).child(indentifier!).child("options").child(choiceId).child("votes").updateChildValues(["\(userId)": true])

    }
    func didAddOption(row:Int, text: String,image: UIImage?) {
        self.messages[row].isBeingEdited = false
        let indentifier = self.messages[row].identifier
        let option = ARPollOption(identifier: UUID().uuidString)
        messagesRef.child(self.threadId!).child(indentifier!).child("options").child(option.identifier!).setValue(["identifier": option.identifier!,"text": text,"type": ARMessageMediaType.option.rawValue])
        if let _ = image {
            self.uploadMedia(pollOption: option, key: indentifier!)
        }
    }

    func didTapCameraButton(row: Int) {
        if let choosePictureMenu = self.choosePictureMenu {
            self.messages[row].isBeingEdited = true
            self.selectedRow = row
            self.present(choosePictureMenu, animated: true, completion: nil)
        }
    }

    func didTapOnAddOption(row:Int) {
        self.messages[row].isBeingEdited = true
        self.tableView.reloadData()
    }
}

