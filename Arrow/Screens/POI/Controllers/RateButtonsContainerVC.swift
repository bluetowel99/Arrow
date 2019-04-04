
import UIKit

protocol RateButtonsContainerDelegate {
    func setRating(ratingType: ARPlaceRating.Key, rating: Float)
}

class RateButtonsContainerVC: UIViewController {

    var ratingType: ARPlaceRating.Key!

    var delegate: RateButtonsContainerDelegate?

    @IBOutlet var containerBackground: UIView!

    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradient()
        setupButtons()
    }

    func setupGradient() {
        let colorLeft = UIColor(red: 207.0 / 255.0, green: 232.0 / 255.0, blue:255.0 / 255.0, alpha: 1.0).cgColor
        let colorRight = UIColor(red: 13.0 / 255.0, green: 139.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor

        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [colorLeft, colorRight]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)

        containerBackground.layer.insertSublayer(gradient, at: 0)
    }

    func setupButtons() {
        resetButtons()

        buttonOne.layer.borderWidth = 3.0
        buttonOne.layer.cornerRadius = 5.0

        buttonTwo.layer.borderWidth = 3.0
        buttonTwo.layer.cornerRadius = 5.0

        buttonThree.layer.borderWidth = 3.0
        buttonThree.layer.cornerRadius = 5.0

        buttonFour.layer.borderWidth = 3.0
        buttonFour.layer.cornerRadius = 5.0

        buttonFive.layer.borderWidth = 3.0
        buttonFive.layer.cornerRadius = 5.0
    }

    func resetButtons() {
        buttonOne.layer.borderColor = UIColor.clear.cgColor
        buttonTwo.layer.borderColor = UIColor.clear.cgColor
        buttonThree.layer.borderColor = UIColor.clear.cgColor
        buttonFour.layer.borderColor = UIColor.clear.cgColor
        buttonFive.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Event Handlers

    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        resetButtons()

        sender.layer.borderColor = UIColor.white.cgColor

        if sender.restorationIdentifier == "button1" {
            delegate?.setRating(ratingType: ratingType, rating: 1.0)
        } else if sender.restorationIdentifier == "button2" {
            delegate?.setRating(ratingType: ratingType, rating: 2.0)
        } else if sender.restorationIdentifier == "button3" {
            delegate?.setRating(ratingType: ratingType, rating: 3.0)
        } else if sender.restorationIdentifier == "button4" {
            delegate?.setRating(ratingType: ratingType, rating: 4.0)
        } else if sender.restorationIdentifier == "button5"{
            delegate?.setRating(ratingType: ratingType, rating: 5.0)
        }
    }
}
