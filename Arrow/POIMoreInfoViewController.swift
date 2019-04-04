
import UIKit

class POIMoreInfoViewController: UIViewController {
    
    @IBOutlet var myScrollView: UIScrollView!
    @IBOutlet var myContentView: UIView!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    //Hours
    @IBOutlet var mondayHours: UILabel!
    @IBOutlet var tuesdayHours: UILabel!
    @IBOutlet var wednesdayHours: UILabel!
    @IBOutlet var thursdayHours: UILabel!
    @IBOutlet var fridayHours: UILabel!
    @IBOutlet var saturdayHours: UILabel!
    @IBOutlet var sundayHours: UILabel!
    
    //Info
    @IBOutlet var reservationLabel: UILabel!
    @IBOutlet var deliveryLabel: UILabel!
    @IBOutlet var takeoutLabel: UILabel!
    @IBOutlet var outdoorSeatingLabel: UILabel!
    @IBOutlet var ambienceLabel: UILabel!
    @IBOutlet var noiseLevelLabel: UILabel!
    @IBOutlet var attireLabel: UILabel!
    @IBOutlet var groupsLabel: UILabel!
    @IBOutlet var kidsLabel: UILabel!
    @IBOutlet var creditCardsLabel: UILabel!
    @IBOutlet var applePayLabel: UILabel!
    @IBOutlet var parkingLabel: UILabel!
    @IBOutlet var bikeParkingLabel: UILabel!
    @IBOutlet var waiterServiceLabel: UILabel!
    @IBOutlet var wifiLabel: UILabel!
    @IBOutlet var alchoholLabel: UILabel!
    
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var reservationsContainer: UIView!
    @IBOutlet weak var deliveryContainer: UIView!
    @IBOutlet weak var takeoutContainer: UIView!
    @IBOutlet weak var outdoorseatingContainer: UIView!
    @IBOutlet weak var ambienceNoiseContainer: UIView!
    @IBOutlet weak var noiseLevelContainer: UIView!
    @IBOutlet weak var attireContainer: UIView!
    @IBOutlet weak var groupContainer: UIView!
    @IBOutlet weak var kidsContainer: UIView!
    @IBOutlet weak var creditCardsContainer: UIView!
    @IBOutlet weak var applePayContainer: UIView!
    @IBOutlet weak var parkingContainer: UIView!
    @IBOutlet weak var bikeParkingContainer: UIView!
    @IBOutlet weak var wifiContainer: UIView!
    @IBOutlet weak var waiterContainer: UIView!
    @IBOutlet weak var alcoholContainer: UIView!
    @IBOutlet weak var hoursContainer: UIView!
    
    /// Set PointOfInterest using during the setup call.
    var pointOfInterest: ARGooglePlace?
    var moreInfo: [String: Any]?
    var hours = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        moreInfo = pointOfInterest?.moreInformation
        hours = pointOfInterest?.openingHours!["weekday_text"] as! [String]
        setupScrollView()
    }
    
    func hideInfomation(_ shouldShow: Bool) {
        hoursContainer.frame = shouldShow ? CGRect(x: 0, y: 92, width: self.view.frame.width, height: 289) : CGRect(x: 0, y: 0, width:  self.view.frame.width, height: 289)
        myScrollView.contentSize = shouldShow ? myContentView.frame.size : self.view.frame.size
        descriptionContainer.isHidden = !shouldShow
        reservationsContainer.isHidden = !shouldShow
        deliveryContainer.isHidden = !shouldShow
        takeoutContainer.isHidden = !shouldShow
        outdoorseatingContainer.isHidden = !shouldShow
        ambienceNoiseContainer.isHidden = !shouldShow
        noiseLevelContainer.isHidden = !shouldShow
        attireContainer.isHidden = !shouldShow
        groupContainer.isHidden = !shouldShow
        kidsContainer.isHidden = !shouldShow
        creditCardsContainer.isHidden = !shouldShow
        applePayContainer.isHidden = !shouldShow
        parkingContainer.isHidden = !shouldShow
        bikeParkingContainer.isHidden = !shouldShow
        wifiContainer.isHidden = !shouldShow
        alcoholContainer.isHidden = !shouldShow
        waiterContainer.isHidden = !shouldShow
    }
    
    func setupScrollView() {
        
        myScrollView.contentSize = myContentView.frame.size
        
        if hours.count > 0 {
            
            var previousDay = ""
            
            for (_, element) in hours.enumerated() {
                
                let day = element.components(separatedBy: ":")[0]
                
                switch day {
                case "Monday":
                    self.mondayHours.text = element.components(separatedBy: "Monday:")[1]
                case "Tuesday":
                    self.tuesdayHours.text = element.components(separatedBy: "Tuesday:")[1]
                case "Wednesday":
                    self.wednesdayHours.text = element.components(separatedBy: "Wednesday:")[1]
                case "Thursday":
                    self.thursdayHours.text = element.components(separatedBy: "Thursday:")[1]
                case "Friday":
                    self.fridayHours.text = element.components(separatedBy: "Friday:")[1]
                case "Saturday":
                    self.saturdayHours.text = element.components(separatedBy: "Saturday:")[1]
                case "Sunday":
                    self.sundayHours.text = element.components(separatedBy: "Sunday:")[1]
                default:
                    print("Not a day")
                    switch previousDay {
                    case "Monday":
                        self.mondayHours.text = "\(self.mondayHours.text ?? "")M,\(element)"
                    case "Tuesday":
                        self.tuesdayHours.text = "\(self.tuesdayHours.text ?? "")M,\(element)"
                    case "Wednesday":
                        self.wednesdayHours.text = "\(self.wednesdayHours.text ?? "")M,\(element)"
                    case "Thursday":
                        self.thursdayHours.text = "\(self.thursdayHours.text ?? "")M,\(element)"
                    case "Friday":
                        self.fridayHours.text = "\(self.fridayHours.text ?? "")M,\(element)"
                    case "Saturday":
                        self.saturdayHours.text = "\(self.saturdayHours.text ?? "")M,\(element)"
                    case "Sunday":
                        self.sundayHours.text = "\(self.sundayHours.text ?? "")M,\(element)"
                    default:
                        print("Not a previous day")
                    }
                }
                previousDay = day
            }
        }
        
        if let shouldShow = moreInfo?["showDetails"] as? Bool {
            hideInfomation(shouldShow)
        }
        
        if let description = moreInfo!["description"] as? String {
            self.descriptionLabel.text = description
        } else {
            self.descriptionContainer.isHidden = true
        }
        
        if let bParking = moreInfo!["bike_parking"] as? Int {
            self.bikeParkingLabel.text = bParking == 1 ? "Yes" : "No"
        }
        
        if let alcohol = moreInfo!["alcohol"] as? Int {
            self.alchoholLabel.text = alcohol  == 1 ? "Yes" : "No"
        }
        
        if let wifi = moreInfo!["wifi"] as? Int {
            self.wifiLabel.text = wifi  == 1 ? "Yes" : "No"
        }
        
        if let delivery = moreInfo!["delivery"] as? Int {
            self.deliveryLabel.text = delivery  == 1 ? "Yes" : "No"
        }
        
        if let ambience = moreInfo!["ambience"] as? String {
            self.ambienceLabel.text = ambience
        }
        
        if let kids = moreInfo!["kids"] as? Int {
            self.kidsLabel.text = kids == 1 ? "Yes" : "No"
        }
        
        if let reservations = moreInfo!["reservations"] as? Int {
            self.reservationLabel.text = reservations == 1 ? "Yes" : "No"
        }
        
        if let parking = moreInfo!["parking"] as? Int {
            self.parkingLabel.text = parking == 1 ? "Yes" : "No"
        }
        
        if let outdoor_seating = moreInfo!["outdoor_seating"] as? Int {
            self.outdoorSeatingLabel.text = outdoor_seating == 1 ? "Yes" : "No"
        }
        
        if let goups = moreInfo!["goups"] as? Int {
            self.groupsLabel.text = goups == 1 ? "Yes" : "No"
        }
        
        if let takeout = moreInfo!["takeout"] as? Int {
            self.takeoutLabel.text = takeout == 1 ? "Yes" : "No"
        }
        
        if let noise_level = moreInfo!["noise_level"] as? String {
            self.noiseLevelLabel.text = noise_level
        }
        
        if let credit_cards = moreInfo!["credit_cards"] as? Int {
            self.creditCardsLabel.text = credit_cards == 1 ? "Yes" : "No"
        }
        
        if let waiter_service = moreInfo!["waiter_service"] as? Int {
            self.waiterServiceLabel.text = waiter_service == 1 ? "Yes" : "No"
        }
        
        if let apple_pay = moreInfo!["apple_pay"] as? Int {
            self.applePayLabel.text = apple_pay == 1 ? "Yes" : "No"
        }
        
        if let attire = moreInfo!["attire"] as? String {
            self.attireLabel.text = attire
        }
    }
    
    //TODO: Not implemented
    @IBAction func submitInfoPressed(_ sender: Any) {
        print("Submitting Information")
    }
}
