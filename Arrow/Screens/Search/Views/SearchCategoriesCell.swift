
import UIKit

// MARK: - SearchCategoriesCellDelegate

protocol SearchCategoriesCellDelegate {
    func searchCategoryCellDidSelect(cell: SearchCategoriesCell, selection: ARSearchCategory?)
}

class SearchCategoriesCell: UITableViewCell {
    
    var numOfColumns: CGFloat = 4.3
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var listStackView: UIStackView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate(set) var categories: [ARSearchCategory]?
    fileprivate(set) var activeCategory: ARSearchCategory?
    
    var delegate: SearchCategoriesCellDelegate?
    
    func setupCell(categories: [ARSearchCategory], activeCategory: ARSearchCategory?) -> Void {
        selectionStyle = .none
        self.categories = categories
        self.activeCategory = activeCategory
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        updateListStackView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categories = nil
        activeCategory = nil
        resetStackView(listStackView)
    }
    
}

// MARK: - UI Helpers

extension SearchCategoriesCell {
    
    fileprivate func updateListStackView() {
        scrollView.showsHorizontalScrollIndicator = false
        resetStackView(listStackView)
        
        let _ = categories?.enumerated().map { index, ctg in
            let newButton = makeCategoryButton(title: ctg.title, image: ctg.image(inBW: false))
            newButton.tag = index
            listStackView.addArrangedSubview(newButton)
            
            let newButtonWidthConst = NSLayoutConstraint(item: newButton, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1 / numOfColumns, constant: -listStackView.spacing)
            scrollView.addConstraint(newButtonWidthConst)
        }
        
        if let scrollViewHeightConstraint = scrollViewHeightConstraint {
            listStackView.removeConstraints([scrollViewHeightConstraint])
        }
        if let listItem = listStackView.subviews.first {
            scrollViewHeightConstraint = NSLayoutConstraint(item: scrollView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: listItem, attribute: .height, multiplier: 1.0, constant: 0.0)
            scrollView.addConstraints([scrollViewHeightConstraint!])
        }
        
        updateCategoryButtons()
        
        layoutIfNeeded()
    }
    
    fileprivate func resetStackView(_ stackView: UIStackView) {
        let _ = listStackView.subviews.map { $0.removeFromSuperview() }
    }
    
    fileprivate func makeCategoryButton(title: String?, image: UIImage?) -> ARButton {
        let button = ARButton(frame: .zero)
        button.clipsToBounds = true
        button.borderWidth = 4.0
        button.cornerRadius = 6.0
        button.enabledBorderColor = .clear
        button.enabledBackgroundColor = .clear
        button.titleLabel?.font = R.font.workSansBlack(size: 12.0)
        button.setTitleColor(R.color.arrowColors.vanillaWhite(), for: .normal)
        button.setTitle(title, for: .normal)
        button.setBackgroundImage(image, for: .normal)
        
        let aspectRatioConst = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0.0)
        button.addConstraint(aspectRatioConst)
        
        button.addTarget(self, action: #selector(categoryButtonPressed(_:)), for: .touchUpInside)
        
        return button
    }
    
    fileprivate func updateCategoryButtons() {
        let hasActiveSelection = activeCategory != nil
        let _ = categories?.enumerated().map { index, category in
            guard let catButton = listStackView.arrangedSubviews[index] as? ARButton else {
                return
            }
            
            if let activeCategory = activeCategory, category.title == activeCategory.title {
                catButton.setBackgroundImage(activeCategory.image(inBW: false), for: .normal)
                catButton.enabledBorderColor = activeCategory.tintColor
            } else {
                catButton.setBackgroundImage(category.image(inBW: hasActiveSelection), for: .normal)
                catButton.enabledBorderColor = .clear
            }
        }
    }
    
}

// MARK: - Event Handlers

extension SearchCategoriesCell {
    
    @IBAction func categoryButtonPressed(_ sender: ARButton) {
        let selectedIndex = sender.tag
        let selectedCategory = categories?[selectedIndex]
        activeCategory = activeCategory?.title == selectedCategory?.title ? nil : selectedCategory
        updateCategoryButtons()
        delegate?.searchCategoryCellDidSelect(cell: self, selection: activeCategory)
    }
    
}
