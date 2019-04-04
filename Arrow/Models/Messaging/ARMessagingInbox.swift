
import UIKit
import FirebaseDatabase
struct ARMessagingInbox {
    /*
    var messageThreads: [ARMessageThread] {
        get {
            
            if let url = R.file.messagesJson() {
                do {
                    let data = try Data(contentsOf: url, options: .mappedIfSafe)
                    let result: [[String:Any]] = try JSONSerialization.jsonObject(with: data, options: []) as! [[String:Any]]
                    
                    var messageThreads = [ARMessageThread]()
                    for messageThreadData in result {
                        if let messageThread = ARMessageThread(with: messageThreadData) {
                            messageThreads.append(messageThread)
                        }
                    }
                    
                    return messageThreads
                } catch let error as NSError {
                    print(error)
                }
            }
            
            return []
        }
    }*/

    var messageThreads: [ARMessageThread] = []
    
    var numberOfItems: Int {
        return messageThreads.count
    }


    
}


extension ARMessagingInbox {
    
    func configure(cell: MessagingInboxTableViewCell, atRow: Int) {
        let thread = messageThreads[atRow]
        cell.titleLabel.text = thread.title
        cell.previewLabel.text = thread.previewText
        cell.timeStampLabel.text = timestamp(for: thread).uppercased()
        cell.typeImageView.image = typeImage(for: thread.type)
        addThreadImage(view: cell.threadImageView, url: thread.imageURL)
        //cell.unreadImageView.isHidden = !thread.isUnread!
        cell.configure()
        
        if atRow == messageThreads.count - 1 {
            cell.dividerView.isHidden = true
        } else {
            cell.dividerView.isHidden = false
        }
    }
    
    func timestamp(for thread: ARMessageThread) -> String {
        guard let date = thread.date else { return "" }
        
        if Calendar.autoupdatingCurrent.isDateInToday(date) {
            return todayDateFormatter.string(from: date)
        } else {
            return pastDateFormatter.string(from: date)
        }
    }
    
    func typeImage(for type: ARMessageThreadType) -> UIImage? {
        switch type {
        case .bubble:
            return R.image.messagesBubble()
        case .direct:
            return R.image.messagesChat()
        case .group:
            return R.image.messagesGroupChat()
        }
    }
    
    func addThreadImage(view: UIImageView, url: URL?) {
        if (url != nil) {
            view.setImage(from: url!)
        }
    }
    
}
