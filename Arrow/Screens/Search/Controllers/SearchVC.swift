
import CoreLocation
import UIKit

final class SearchVC: ARKeyboardViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.search()
    static var kStoryboardIdentifier: String? = "SearchVC"
    
    fileprivate let maxMainCategoriesHeight: CGFloat = 111.0
    fileprivate let minMainCategoriesHeight: CGFloat = 30.0
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mainCategoriesStackView: UIStackView!
    @IBOutlet weak var mainCategoriesStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var activeMainCategory: ARMainCategory?
    fileprivate var activeSubCategory: ARSearchCategory?
    
    fileprivate var poiStore = ARPOIStore()
    fileprivate var results = [ARGooglePlace]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupMainCategoryButtons()
        updateSearchResults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationBarTitleStyle = .compactLogo
        isNavigationBarBackTextHidden = true
        setupNavigationBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
    }
    
}

// MARK: - UI Helpers

extension SearchVC {
    
    fileprivate func setupView() {
        useNavigationBarItem = true
        
        searchTextField.clearButtonMode = .always
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingDidChange(_:)), for: .editingChanged)
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingDidEnd(_:)), for: .editingDidEnd)
        
        collapseMainCategories(false)
    }
    
    fileprivate func setupTableView() {
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 85.0
        tableView.separatorStyle = .none
        tableView.register(R.nib.searchCategoriesCell)
        tableView.register(R.nib.searchSectionHeader(), forHeaderFooterViewReuseIdentifier: SearchSectionHeader.reuseIdentifier)
        tableView.register(R.nib.landmarkCell)
    }
    
    fileprivate func setupNavigationBarButtons() {
        let filterBarButtonItem = UIBarButtonItem(image: R.image.searchFiltersIcon(), style: .done, target: self, action: #selector(filtersButtonPressed(_:)))
        navigationItem.rightBarButtonItems = [filterBarButtonItem]
        
//        let mapBarButtonItem = UIBarButtonItem(title: "MAP", style: .done, target: self, action: #selector(mapButtonPressed(_:)))
//        let textAttr = [NSAttributedStringKey.font: R.font.alegreyaSansBlack(size: 16.0)!,
//                        NSAttributedStringKey.foregroundColor: R.color.arrowColors.slateGray()]
//        mapBarButtonItem.setTitleTextAttributes(textAttr, for: .normal)
//        navigationItem.leftBarButtonItems = [mapBarButtonItem]
    }
    
    fileprivate func setupMainCategoryButtons() {
        for category in ARMainCategory.allValues {
            let catButton = ARButton(frame: .zero)
            catButton.borderWidth = 4.0
            catButton.cornerRadius = 6.0
            catButton.clipsToBounds = true
            catButton.enabledBorderColor = .clear
            catButton.enabledBackgroundColor = .clear
            catButton.titleLabel?.font = R.font.workSansExtraBold(size: 14.0)
            catButton.setTitle(category.title, for: .normal)
            
            // Use tag to pass category associated with each button.
            catButton.tag = Int(category.rawValue)
            catButton.addTarget(self, action: #selector(mainCategoryButtonPressed(_:)), for: .touchUpInside)
            
            mainCategoriesStackView.addArrangedSubview(catButton)
            
            let widthConstraint = NSLayoutConstraint(item: catButton, attribute: .width, relatedBy: .equal, toItem: mainCategoriesStackView, attribute: .width, multiplier: 1 / 3.0, constant: -mainCategoriesStackView.spacing)
            mainCategoriesStackView.addConstraints([widthConstraint])
        }
        
        resetMainCategoryButtons()
    }
    
    fileprivate func resetMainCategoryButtons() {
        let hasActiveSelection = activeMainCategory != nil
        
        // Reset all buttons to neutral state.
        let _ = mainCategoriesStackView.arrangedSubviews.enumerated().map {
            guard let catButton = $1 as? ARButton,
                let category = ARMainCategory(rawValue: UInt($0)) else {
                    return
            }
            
            catButton.setBackgroundImage(category.image(inBW: hasActiveSelection), for: .normal)
            catButton.enabledBackgroundColor = R.color.arrowColors.stormGray().withAlphaComponent(0.4)
            catButton.enabledBorderColor = .clear
        }
    }
    
    fileprivate func collapseMainCategories(_ collapse: Bool) {
        let newHeight = collapse ? minMainCategoriesHeight : maxMainCategoriesHeight
        
        guard mainCategoriesStackViewHeightConstraint.constant != newHeight else {
            return
        }
        
        mainCategoriesStackViewHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
            let _ = self.mainCategoriesStackView.arrangedSubviews.map {
                ($0 as? ARButton)?.backgroundImageView?.alpha = collapse ? 0.0 : 1.0
            }
        }
    }
    
    fileprivate func updateMainCategoryButtons() {
        resetMainCategoryButtons()
        
        if let activeCategory = activeMainCategory {
            let selectedCategoryButton = mainCategoriesStackView.arrangedSubviews[Int(activeCategory.rawValue)] as? ARButton
            selectedCategoryButton?.enabledBorderColor = activeCategory.tintColor
            selectedCategoryButton?.enabledBackgroundColor = activeCategory.tintColor.withAlphaComponent(0.7)
            selectedCategoryButton?.setBackgroundImage(activeCategory.image(inBW: false), for: .normal)
        }
    }
    
    fileprivate func toggleMainCategorySelection(to category: ARMainCategory?) {
        activeMainCategory = activeMainCategory == category ? nil : category
        activeSubCategory = nil
        // Reset search query's text field if there's an active category selected.
        if let _ = activeMainCategory {
            searchTextField.text = nil
        }
        
        updateSearchResults()
        updateMainCategoryButtons()
    }
    
    fileprivate func showPOIDetailsScreen(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        let poiDetailsVC = POIDetailsVC.instantiate()
        poiDetailsVC.setup(pointOfInterest: poi, loadFromServer: true)
        navigationController?.pushViewController(poiDetailsVC, animated: true)
    }
    
    fileprivate func showNavigationScreen(for poi: ARGooglePlace?) {
        guard let poi = poi else {
            return
        }
        
        let navigationVC = MapNavigationVC.instantiate()
        navigationVC.place = poi
        navigationController?.pushViewController(navigationVC, animated: true)
    }
    
    func getSearchCategoriesCell(for tableView: UITableView, at indexPath: IndexPath) -> SearchCategoriesCell? {
        if let activeMainCategory = activeMainCategory {
            let categoriesCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchCategoriesCell, for: indexPath)
            categoriesCell?.setupCell(categories: activeMainCategory.allSubCategories, activeCategory: activeSubCategory)
            categoriesCell?.delegate = self
            return categoriesCell
        }
        
        return nil
    }
    
    func getLandmarkCell(for tableView: UITableView, at indexPath: IndexPath) -> LandmarkCell? {
        let landmarkCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.landmarkCell, for: indexPath)
        landmarkCell?.delegate = self
        let place = results[indexPath.row]
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distance = platform.locationManager.currentLocalizedDistanceFrom(placeLocation)
        landmarkCell?.setupCell(landmark: place, localizedDistance: distance, thumbnailWidth: 55.0)
        return landmarkCell
    }
    
    fileprivate func updateSearchResults() {
        // Reset results
        results.removeAll()
        tableView.reloadData()
        
        // Perform new query
        platform.locationManager.getCurrentLocation(forceRefresh: false) { location in
            guard let location = location else {
                print("Search could not get user's location.")
                return
            }
            
            var query = self.searchTextField.text ?? ""
            if let subCategoryTitle = self.activeSubCategory?.searchQuery {
                query = "\(query) \(subCategoryTitle) "
            }
            query = "\(query)\(self.activeMainCategory?.searchQuery ?? "")"
            
            guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            
            let radius = 48280  // 30 miles
            self.poiStore.searchWithKeyword(query, lat: location.coordinate.latitude, lng: location.coordinate.longitude, radius: radius, rankBy: .distance, openNow: nil, minPrice: nil, maxPrice: nil, forceRefresh: true) { places in
                self.results = places ?? [ARGooglePlace]()
                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - Event Handlers

extension SearchVC {
    
    @IBAction func filtersButtonPressed(_ sender: AnyObject) {
        let searchFilterVC = SearchFilterVC.instantiate()
        searchFilterVC.delegate = self
        let navController = UINavigationController(rootViewController: searchFilterVC)
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func mapButtonPressed(_ sender: AnyObject) {
        // TODO(kia): Switch to map-view screen.
    }
    
    @IBAction func searchTextFieldEditingDidChange(_ sender: Any) {
        toggleMainCategorySelection(to: nil)
        updateSearchResults()
    }
    
    @IBAction func searchTextFieldEditingDidEnd(_ sender: Any) {
        toggleMainCategorySelection(to: nil)
        updateSearchResults()
    }
    
    @IBAction func mainCategoryButtonPressed(_ sender: AnyObject) {
        guard let catIndex = (sender as? ARButton)?.tag else {
            return
        }
        
        let category = ARMainCategory(rawValue: UInt(catIndex))
        toggleMainCategorySelection(to: category)
    }
    
}

// MARK: - UITextFieldDelegate Implementation

extension SearchVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

// MARK: - UITableViewDataSource Implementation

extension SearchVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return activeMainCategory == nil ? 0 : 1
        case 1:
            return results.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch indexPath.section {
        case 0:
            cell = getSearchCategoriesCell(for: tableView, at: indexPath)
        case 1:
            cell = getLandmarkCell(for: tableView, at: indexPath)
        default:
            break
        }
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate Implementation

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return SearchSectionHeader.height
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchSectionHeader.reuseIdentifier) as? SearchSectionHeader
            var sectionTitle = ""
            if let subCategoryTitle = activeSubCategory?.headerTitle {
                sectionTitle = subCategoryTitle
            } else if let mainCategoryTitle = activeMainCategory?.headerTitle {
                sectionTitle = mainCategoryTitle
            }
            
            if sectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                sectionTitle = "Search Results"
            }
            
            header?.setupHeader(title: sectionTitle)
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var poi = results[indexPath.row]
        getPlaceDetails(placeId: poi.placeId) { (googlePlace, error) in
            if let place = googlePlace {
                poi.copyNonNilData(newPOI: place)
            }
        }
        showPOIDetailsScreen(for: poi)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Collapse categories on scroll, only if tableview has some rows.
        guard results.isEmpty == false else {
            return
        }
        
        let shouldCollapse = scrollView.contentOffset.y > 0.0
        collapseMainCategories(shouldCollapse)
    }
    
}

// MARK: - Networking

extension SearchVC {
    
    fileprivate func getPlaceDetails(placeId: String, callback: ((ARGooglePlace?, NSError?) -> Void)?) {
        let request = GetPlaceRequest(platform: platform, placeId: placeId)
        let _ = networkSession?.send(request) { result in
            switch result {
            case .success(let place):
                callback?(place, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}

// MARK: - SearchCategoriesCellDelegate

extension SearchVC: SearchCategoriesCellDelegate {
    
    func searchCategoryCellDidSelect(cell: SearchCategoriesCell, selection: ARSearchCategory?) {
        activeSubCategory = selection
        searchTextField.text = nil
        updateSearchResults()
    }
    
}

// MARK: - SearchFilterVCDelegate Implementation

extension SearchVC: SearchFilterVCDelegate {
    
    func searchFilterVCDidPressApplyButton(controller: SearchFilterVC, filters: ARFilterConfig) {
        // TODO: Apply filters to current search.
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: -

extension SearchVC: LandmarkCellDelegate {
    
    func landmarkCellDidPressNavigate(cell: LandmarkCell) {
        showNavigationScreen(for: cell.place)
    }
    
}
