
import CoreLocation
import UIKit

struct ARFilterConfig {
    var openNow: Bool = false
    var priceLevels: [Int]?
    var sortBy: ARSearchSortFilter = .distance
    var distance: ARSearchDistanceFilter = .fifthShortest
}

final class SearchFilterVC: ARViewController, StoryboardViewController {
    
    static var kStoryboard: UIStoryboard = R.storyboard.searchFilter()
    static var kStoryboardIdentifier: String? = "SearchFilterVC"
    
    @IBOutlet weak var openNowButton: ARButton!
    @IBOutlet weak var pricesStackView: UIStackView!
    @IBOutlet weak var sortByButton: ARButton!
    @IBOutlet weak var sortByArrowImageView: UIImageView!
    @IBOutlet weak var sortByStackView: UIStackView!
    @IBOutlet weak var distanceButton: ARButton!
    @IBOutlet weak var distanceArrowImageView: UIImageView!
    @IBOutlet weak var distanceStackView: UIStackView!
    @IBOutlet weak var applyButton: UIButton!
    
    var filters = ARFilterConfig()
    var delegate: SearchFilterVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reloadView(with: filters)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Filter"
        isNavigationBarBackTextHidden = true
        
        let applyBarButton = UIBarButtonItem(title: "APPLY", style: .done, target: self, action: #selector(applyButtonPressed(_:)))
        navigationItem.rightBarButtonItem = applyBarButton
        let resetBarButton = UIBarButtonItem(title: "RESET", style: .done, target: self, action: #selector(resetButtonPressed(_:)))
        navigationItem.leftBarButtonItem = resetBarButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
    }
    
}

// MARK: - UI Helpers

extension SearchFilterVC {
    
    fileprivate func setupView() {
        setupSortByOptions()
        setupDistanceOptions()
    }
    
    fileprivate func setupSortByOptions() {
        let allTitles = ARSearchSortFilter.allValues.map { $0.title }
        populateOptionsStackView(sortByStackView, withTitles: allTitles)
    }
    
    fileprivate func setupDistanceOptions() {
        let allTitles = ARSearchDistanceFilter.allValues.map { $0.title }
        populateOptionsStackView(distanceStackView, withTitles: allTitles)
    }
    
    fileprivate func populateOptionsStackView(_ stackView: UIStackView, withTitles allTitles: [String?]) {
        let totalCount = allTitles.count
        let _ = allTitles.enumerated().map { index, title in
            let optionRowView = SearchFilterOptionView(frame: .zero)
            optionRowView.setupView(title: title, isSelected: false, isLastRow: index == totalCount - 1)
            stackView.addArrangedSubview(optionRowView)
            let heightConstraint = NSLayoutConstraint(item: optionRowView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 50.0)
            optionRowView.addConstraint(heightConstraint)
        }
    }
    
    fileprivate func reloadView(with config: ARFilterConfig) {
        openNowButton.isSelected = config.openNow
    }
    
    fileprivate func resetToDefault() {
        filters = ARFilterConfig()
        reloadView(with: filters)
    }
    
}

// MARK: - Event Handlers

extension SearchFilterVC {
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {
        delegate?.searchFilterVCDidPressApplyButton(controller: self, filters: filters)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        resetToDefault()
    }
    
}

// MARK: - SearchFilterVCDelegate Definition

protocol SearchFilterVCDelegate {
    func searchFilterVCDidPressApplyButton(controller: SearchFilterVC, filters: ARFilterConfig)
}
