
import UIKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

enum ARCategories: String {
    case Food = "food"
    case Drink = "drinks"
}

extension SpecialDetailViewController: RatedSpecialDelegate {
    
    func specialWasRated(_ special: [String : Any]) {
        var selectedCat = selectedCategory! == ARCategories.Drink.rawValue ? sortedDrinks : sortedDishes
        var selectedSub = selectedCategory! == ARCategories.Drink.rawValue ? specialDrinkSubcategories : specialDishSubcategories
        let ratedSpecial = special
        selectedCat[selectedSub[(ratedIndexPath?.section)!]]![(ratedIndexPath?.row)!] = ratedSpecial
        
        
        if selectedCategory! == ARCategories.Drink.rawValue {
            sortedDrinks = selectedCat
        } else {
            sortedDishes = selectedCat
        }
        
        myTableView.reloadData()
    }
}

extension SpecialDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = ""
        if selectedCategory! == ARCategories.Drink.rawValue {
            text = specialDrinkSubcategories[section].uppercased()
        } else {
            text = specialDishSubcategories[section].uppercased()
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = UIColor.white
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 30))
        label.font = UIFont.init(name: "AlegreyaSans-Bold", size: 16)
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.init(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        label.text = text
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedCategory! == ARCategories.Drink.rawValue {
            return Set(sortedDrinks.keys).count
        } else {
            return Set(sortedDishes.keys).count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCategory! == ARCategories.Drink.rawValue {
            return (sortedDrinks[specialDrinkSubcategories[section]]?.count)!
        } else {
            return (sortedDishes[specialDishSubcategories[section]]?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCategory! == ARCategories.Drink.rawValue {
            return specialDrinkSubcategories[section].uppercased()
        } else {
            return specialDishSubcategories[section].uppercased()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if #available(iOS 11.0, *) {
            view.insetsLayoutMarginsFromSafeArea = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SpecialsTableViewCell
        
        let selectedCat = selectedCategory! == ARCategories.Drink.rawValue ? sortedDrinks : sortedDishes
        let selectedSub = selectedCategory! == ARCategories.Drink.rawValue ? specialDrinkSubcategories : specialDishSubcategories
        
        if selectedCat[selectedSub[indexPath.section]] != nil {
            
            let numPeople = Int(selectedCat[selectedSub[indexPath.section]]![indexPath.row]["ratings_count"] as! Double)
            
            var ratingText = ""
            
            if numPeople >= 1 {
                cell.howManyOrderedLabel.font = UIFont.init(name: "AlegreyaSans-Medium", size: 16)
                ratingText = numPeople > 1 ? "\(numPeople) people ordered this" : "\(numPeople) person ordered this"
            } else {
                cell.howManyOrderedLabel.font = UIFont.init(name: "AlegreyaSans-Bold", size: 16)
                ratingText = "Be the first to rate this!"
            }
            
            cell.howManyOrderedLabel.text = ratingText
            
            let rating = selectedCat[selectedSub[indexPath.section]]![indexPath.row]["average_rating"] as! Double
            cell.ratingLabel.text = "\(rating.rounded(toPlaces: 1))"
            cell.itemDetailLabel.text = selectedCat[selectedSub[indexPath.section]]![indexPath.row]["description"] as? String
            cell.priceLabel.text =  "$\(selectedCat[selectedSub[indexPath.section]]![indexPath.row]["price"] as? NSNumber ?? 0)"
            cell.itemImage.setImage(from: URL.init(string: (selectedCat[selectedSub[indexPath.section]]![indexPath.row]["photo"] as? String)!)!)
            cell.ratingButton.accessibilityIdentifier = "\(indexPath)"
            cell.ratingButton.addTarget(self, action: #selector(rateSpecial(sender:)), for: .touchUpInside)
            
            cell.photoButton.accessibilityIdentifier = "\(indexPath)"
            cell.photoButton.addTarget(self, action: #selector(enlargeSpecialPhoto(sender:)), for: .touchUpInside)
            
            let color = UIColor.init(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
            let font = [NSAttributedStringKey.font: UIFont(name: "WorkSans-ExtraBold", size: 16)!, NSAttributedStringKey.foregroundColor: color]
            let attributedString = NSMutableAttributedString(string: (selectedCat[selectedSub[indexPath.section]]![indexPath.row]["name"] as? String)! , attributes: font)
            cell.itemNameLabel.attributedText = attributedString
            //  cell.itemNameLabel.adjustsFontSizeToFitWidth = true
            //  cell.itemNameLabel.minimumScaleFactor = 0.1
            
            let color1 = UIColor.init(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
            let font1 = [NSAttributedStringKey.font: UIFont(name: "AlegreyaSans-Bold", size: 14)!, NSAttributedStringKey.foregroundColor: color1]
            let attributedString1 =  NSMutableAttributedString(string: (selectedCat[selectedSub[indexPath.section]]![indexPath.row]["description"] as? String)! , attributes: font1)
            cell.itemDetailLabel.attributedText = attributedString1
            //  cell.itemDetailLabel.adjustsFontSizeToFitWidth = true
            //  cell.itemDetailLabel.minimumScaleFactor = 0.5
            
            let ratings = selectedCat[selectedSub[indexPath.section]]![indexPath.row]["ratings"] as? [[String: Any]]
            
            var ratingsImage = UIImage.init(named: "fill155")
            var ratingsBG = UIColor.init(red: 196/255, green: 196/255, blue: 196/255, alpha: 1)
            
            for (_, rating) in (ratings?.enumerated())! {
                if let currentUser = rating["user"] as? Int {
                    if ARPlatform.shared.userSession?.user?.identifier != nil {
                        if currentUser == Int((ARPlatform.shared.userSession?.user?.identifier)!) {
                            ratingsImage = UIImage.init(named: "\(Int(truncating: rating["rating"] as! NSNumber))")
                            ratingsBG = UIColor.init(red: 13/255, green: 139/255, blue: 255/255, alpha: 1)
                        }
                    }
                }
            }
            cell.ratingImage.image = ratingsImage
            cell.rateView.backgroundColor = ratingsBG
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func rateSpecial(sender: UIButton) {
        
        var ratedArray = [Int]()
        for (_, element) in (sender.accessibilityIdentifier?.enumerated())! {
            if let number = Int(String(element)) {
                ratedArray.append(number)
            }
        }
        var selectedCat = selectedCategory! == ARCategories.Drink.rawValue ? sortedDrinks : sortedDishes
        let selectedSub = selectedCategory! == ARCategories.Drink.rawValue ? specialDrinkSubcategories : specialDishSubcategories
        
        ratedIndexPath = IndexPath.init(row: ratedArray[1], section: ratedArray[0])
        selectedSpecial = selectedCat[selectedSub[(ratedIndexPath?.section)!]]![(ratedIndexPath?.row)!]
        let new = ratedIndexPath
        selectedCat[selectedSub[(new?.section)!]]![(new?.row)!] = ["":""]
        self.myTableView.scrollToRow(at: ratedIndexPath!, at: .top, animated: false)
        
        self.performSegue(withIdentifier: "rate", sender: self)
    }
    
    @objc func enlargeSpecialPhoto(sender: UIButton) {
        
        var ratedArray = [Int]()
        for (_, element) in (sender.accessibilityIdentifier?.enumerated())! {
            if let number = Int(String(element)) {
                ratedArray.append(number)
            }
        }
        var selectedCat = selectedCategory! == ARCategories.Drink.rawValue ? sortedDrinks : sortedDishes
        let selectedSub = selectedCategory! == ARCategories.Drink.rawValue ? specialDrinkSubcategories : specialDishSubcategories
        
        ratedIndexPath = IndexPath.init(row: ratedArray[1], section: ratedArray[0])
        selectedSubCategory = selectedSub[(ratedIndexPath?.section)!]
        selectedSpecial = selectedCat[selectedSubCategory!]![(ratedIndexPath?.row)!]
        let new = ratedIndexPath
        selectedCat[selectedSub[(new?.section)!]]![(new?.row)!] = ["":""]
        self.performSegue(withIdentifier: "photo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "rate" {
            let vc = segue.destination as! RateSpecialViewController
            vc.delegate = self
            vc.special = selectedSpecial
            vc.modalPresentationStyle = .overCurrentContext
        } else if segue.identifier == "photo" {
            let vc = segue.destination as! SpecialPhotoViewController
            vc.special = selectedSpecial
            vc.placeName = placeName
            vc.subCategory = selectedSubCategory!
        }
    }
}

class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: +src.view.frame.size.width, y: (src.navigationController?.navigationBar.frame.height)!)
        
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: (src.navigationController?.navigationBar.frame.height)!)
        },
                       completion: { finished in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}

extension SpecialDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let displayText = selectedCategory == ARCategories.Drink.rawValue ? specialDrinkSubcategories[indexPath.row] : specialDishSubcategories[indexPath.row]
        let tempLabel = UILabel()
        tempLabel.numberOfLines = 0
        tempLabel.text = displayText
        let labelSize = tempLabel.intrinsicContentSize
        
        return CGSize(width:labelSize.width, height: labelSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard selectedCategory == ARCategories.Drink.rawValue else {
            return specialDishSubcategories.count
        }
        return specialDrinkSubcategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SpecialDetailCollectionViewCell
        let displayText = selectedCategory == ARCategories.Drink.rawValue ? specialDrinkSubcategories[indexPath.row] : specialDishSubcategories[indexPath.row]
        let attributedText = NSMutableAttributedString(string: displayText.uppercased())
        let textRange = NSMakeRange(0, displayText.count)
        
        if selectedIndexPath == indexPath {
            attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: textRange)
            cell.subCategoryLabel.attributedText = attributedText
            cell.subCategoryLabel.textColor = UIColor.black
        } else {
            cell.subCategoryLabel.attributedText = attributedText
            cell.subCategoryLabel.textColor = UIColor.init(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = IndexPath.init(row: 0, section: indexPath.row)
        selectedIndexPath = indexPath
        self.myTableView.scrollToRow(at: id, at: .top, animated: true)
    }
}

extension SpecialDetailViewController {
    
    func createButton() {
        
        let testFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let buttonView: UIView = UIView(frame: testFrame)
        let foodButtonImageName = selectedCategory == ARCategories.Food.rawValue ? "foodSelected" : "food"
        let drinkButtonImageName = selectedCategory == ARCategories.Drink.rawValue ? "drinkSelected" : "drink"
        
        let foodButton = UIButton(type: UIButtonType.custom) as UIButton
        foodButton.frame = CGRect(x: 90, y: -5, width: 61, height: 50)
        foodButton.setImage(UIImage.init(named: foodButtonImageName), for: .normal)
        foodButton.imageView?.clipsToBounds = true
        foodButton.imageView?.contentMode = .scaleAspectFill
        foodButton.backgroundColor = UIColor.clear
        foodButton.setTitle("1", for: .normal)
        foodButton.tag = 1
        foodButton.addTarget(self, action: #selector(setCategory), for: .touchDown)
        
        let drinkButton =  UIButton(type: UIButtonType.custom) as UIButton
        drinkButton.frame =  CGRect(x: 155, y: -5, width: 61, height: 50)
        drinkButton.backgroundColor = UIColor.clear
        drinkButton.setImage(UIImage.init(named: drinkButtonImageName), for: .normal)
        drinkButton.imageView?.clipsToBounds = true
        drinkButton.imageView?.contentMode = .scaleAspectFill
        drinkButton.tag = 2
        drinkButton.setTitle("2", for: .normal)
        drinkButton.addTarget(self, action: #selector(setCategory), for: .touchDown)
        
        buttonView.addSubview(foodButton)
        buttonView.addSubview(drinkButton)
        
        self.navigationItem.titleView = buttonView
    }
    
    @objc func setCategory(sender: UIButton) {
        
        guard sender.tag == 1 else {
            selectedCategory = ARCategories.Drink.rawValue
            return
        }
        selectedCategory = ARCategories.Food.rawValue
    }
}

class SpecialDetailViewController: UIViewController {
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet var editViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var editToTableConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewFooterConstraint: NSLayoutConstraint!
    @IBOutlet var litPointsView: UIView!
    
    var selectedSpecial = [String: Any]()
    var placeName = ""
    
    var selectedIndexPath: IndexPath? {
        didSet {
            myCollectionView.reloadData()
        }
    }
    
    var ratedIndexPath: IndexPath? {
        didSet {
            myTableView.reloadData()
        }
    }
    
    var selectedCategory: String? {
        didSet {
            createButton()
            myTableView.reloadData()
            myCollectionView.reloadData()
        }
    }
    
    @IBOutlet var editMenuButton: UIButton!
    @IBOutlet var addItemlabel: UILabel!
    
    var specialDishes = [[String: Any]]()
    var specialDrinks = [[String: Any]]()
    
    var specialDrinkSubcategories = [String]()
    var specialDishSubcategories = [String]()
    @IBOutlet var litViewContainer: UIView!
    var selectedSubCategory: String?
    
    var sortedDishes = [String: [Dictionary<String, Any>]]()
    var sortedDrinks = [String: [Dictionary<String, Any>]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let direction: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for d in direction {
            let swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(changeCat))
            swipeGesture.direction = d
            myTableView.addGestureRecognizer(swipeGesture)
        }
        
        createButton()
        litViewContainer.layer.masksToBounds = false
        litViewContainer.layer.shadowColor = UIColor.init(red: 167/255, green: 167/255, blue: 167/255, alpha: 1).cgColor
        litViewContainer.layer.shadowOffset = CGSize.init(width: 0, height:-2)
        litViewContainer.layer.shadowRadius = 2
        litViewContainer.layer.shadowOpacity = 0.7
        
        tableViewFooterConstraint.constant = 33
        
        specialDrinkSubcategories = parseSubCategories(dictionaries: specialDrinks, cat:  ARCategories.Drink.rawValue)
        specialDishSubcategories = parseSubCategories(dictionaries: specialDishes, cat:  ARCategories.Food.rawValue)
        selectedIndexPath = IndexPath.init(row: 0, section: 0)
    }
    
    @objc func changeCat() {
        if selectedCategory == ARCategories.Drink.rawValue {
            selectedCategory = ARCategories.Food.rawValue
        } else {
            selectedCategory = ARCategories.Drink.rawValue
        }
    }
    
    @IBAction func editMenu(_ sender: Any) {
        
        guard tableViewFooterConstraint.constant == 33 else {
            UIView.animate(withDuration: 0.2) {
                self.tableViewFooterConstraint.constant = 33
                self.addItemlabel.isHidden = true
                self.editMenuButton.isHidden = true
                self.view.layoutIfNeeded()
            }
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.tableViewFooterConstraint.constant = 110
            self.addItemlabel.isHidden = false
            self.editMenuButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func parseSubCategories(dictionaries: [[String: Any]], cat: String) -> [String] {
        
        var keys = [String]()
        
        for (_, element) in dictionaries.enumerated() {
            
            let name = element["name"] as! String
            keys.append(name)
            
            if let items = element["items"] as? [[String: Any]] {
                if cat == ARCategories.Drink.rawValue {
                    sortedDrinks[name] = items
                } else {
                    sortedDishes[name] = items
                }
            }
        }
        let set = Set(keys)
        return Array(set)
    }
}
