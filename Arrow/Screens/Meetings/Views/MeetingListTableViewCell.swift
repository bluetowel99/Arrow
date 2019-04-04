

import UIKit


class MeetingListTableViewCell: UITableViewCell {

    @IBOutlet weak var meetingTitleLabel: UILabel!
    @IBOutlet weak var meetingDateLabel: UILabel!
    
    func setup(meeting: ARMeeting) {
        selectionStyle = .none
        
        meetingTitleLabel.text = meeting.title
        
        if(meeting.date == nil) {
            meetingDateLabel.text = "NO TIME"
        } else {
            let nowString = relativeDateFormatter.string(from: meeting.date!)
            meetingDateLabel.text = nowString
        }
    }
}
