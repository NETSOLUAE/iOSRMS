//
//  ButtonBarPagerTabStripViewControllerSalary.swift
//  RMS
//
//  Created by Mac Mini on 8/23/17.
//  Copyright © 2017 Netsol. All rights reserved.
//

import Foundation
import UIKit

open class ButtonBarPagerTabStripViewControllerSalary: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var settings = ButtonBarPagerTabStripSettings()
    
    public var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarViewCellSalary>!
    
    public var changeCurrentIndex: ((_ oldCell: ButtonBarViewCellSalary?, _ newCell: ButtonBarViewCellSalary?, _ animated: Bool) -> Void)?
    public var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarViewCellSalary?, _ newCell: ButtonBarViewCellSalary?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?
    
    @IBOutlet public weak var buttonBarView: ButtonBarView!
    
    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
        }()
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarItemSpec = .nibFile(nibName: "ButtonBarSalary", bundle: Bundle(for: ButtonBarViewCellSalary.self), width: { [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            var width = 100
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = childItemInfo.title
            if (childItemInfo.title == "Policy Details") {
                width = 105
            } else {
                width = 145
            }
            let buttonBarWidth = self?.settings.style.buttonBarWidth ?? CGFloat(width)
            return buttonBarWidth + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
        })
        
        let buttonBarViewAux = buttonBarView ?? {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            let buttonBarHeight = settings.style.buttonBarHeight ?? 14
            let buttonBarWidth = settings.style.buttonBarWidth ?? 145
            let buttonBar = ButtonBarView(frame: CGRect(x: 0, y: 0, width: buttonBarWidth, height: buttonBarHeight), collectionViewLayout: flowLayout)
            buttonBar.backgroundColor = .orange
            buttonBar.selectedBar.backgroundColor = .black
            buttonBar.autoresizingMask = .flexibleWidth
            var newContainerViewFrame = containerView.frame
            newContainerViewFrame.origin.y = buttonBarHeight
            newContainerViewFrame.size.height = containerView.frame.size.height - (buttonBarHeight - containerView.frame.origin.y)
            containerView.frame = newContainerViewFrame
            return buttonBar
            }()
        buttonBarView = buttonBarViewAux
        
        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumInteritemSpacing ?? flowLayout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsets(top: sectionInset.top, left: settings.style.buttonBarLeftContentInset ?? sectionInset.left, bottom: sectionInset.bottom, right: settings.style.buttonBarRightContentInset ?? sectionInset.right)
        
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor ?? buttonBarView.backgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        
        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        buttonBarView.selectedBarVerticalAlignment = settings.style.selectedBarVerticalAlignment
        
        // register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"CellSalary")
        case .cellClass:
            buttonBarView.register(ButtonBarViewCellSalary.self, forCellWithReuseIdentifier:"CellSalary")
        }
        //-
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isViewAppearing || isViewRotating else { return }
        
        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
        // a) The view is appearing.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
        //    when the view is shown and when the view *frame(s)* are actually set
        //    (we need the view frame's to have been set to work out the size's and on the
        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
        //    aren't set correctly)
        // b) The view is rotating.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
        //    *new* frame so that the buttonBarView cell's actually get resized correctly
        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
        // When the view first appears or is rotated we also need to ensure that the barButtonView's
        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
        // tab/cell may end up either skewed or off screen after a rotation otherwise)
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
    }
    
    // MARK: - Public Methods
    
    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded else { return }
        buttonBarView.reloadData()
        cachedCellWidths = calculateWidths()
        buttonBarView.moveTo(index: currentIndex, animated: false, swipeDirection: .none, pagerScroll: .yes)
    }
    
    open func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let collectionViewAvailiableWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        
        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)
        
        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
    
    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveTo(index: toIndex, animated: false, swipeDirection: toIndex < fromIndex ? .right : .left, pagerScroll: .yes)
        
        if let changeCurrentIndex = changeCurrentIndex {
            let oldIndexPath = IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)
            let newIndexPath = IndexPath(item: currentIndex, section: 0)
            
            let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
            changeCurrentIndex(cells.first!, cells.last!, true)
        }
    }
    
    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .yes)
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldIndexPath = IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)
            let newIndexPath = IndexPath(item: currentIndex, section: 0)
            
            let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
            changeCurrentIndexProgressive(cells.first!, cells.last!, progressPercentage, indexWasChanged, true)
        }
    }
    
    private func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [ButtonBarViewCellSalary?] {
        let cells = indexPaths.map { buttonBarView.cellForItem(at: $0) as? ButtonBarViewCellSalary }
        
        if reload {
            let indexPathsToReload = cells.enumerated()
                .flatMap { index, cell in
                    return cell == nil ? indexPaths[index] : nil
                }
                .flatMap { (indexPath: IndexPath) -> IndexPath? in
                    return (indexPath.item >= 0 && indexPath.item < buttonBarView.numberOfItems(inSection: indexPath.section)) ? indexPath : nil
            }
            
            if !indexPathsToReload.isEmpty {
                buttonBarView.reloadItems(at: indexPathsToReload)
            }
        }
        
        return cells
    }
    
    // MARK: - UICollectionViewDelegateFlowLayut
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != currentIndex else { return }
        
        buttonBarView.moveTo(index: indexPath.item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        shouldUpdateButtonBarView = false
        
        let oldIndexPath = IndexPath(item: currentIndex, section: 0)
        let newIndexPath = IndexPath(item: indexPath.item, section: 0)
        
        let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: collectionViewDidLoad)
        
        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(cells.first!, cells.last!, 1, true, true)
            }
        } else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(cells.first!, cells.last!, true)
            }
        }
        
        if (isHomeViewDidLoad) {
            isHomeViewDidLoad = !isHomeViewDidLoad
            buttonBarView.reloadItems(at: [oldIndexPath])
        }
        moveToViewController(at: indexPath.item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellSalary", for: indexPath) as? ButtonBarViewCellSalary else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCellSalary")
        }
        
        collectionViewDidLoad = true
        
        let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
        let indicatorInfo = childController.indicatorInfo(for: self)
        
        cell.label.text = indicatorInfo.title
        cell.label.font = UIFont.systemFont(ofSize: 14)
        cell.label.textColor = settings.style.buttonBarItemTitleColor
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
        
        if (isHomeViewDidLoad) {
            if (indexPath.row == 0){
                cell.imageView.image = indicatorInfo.highlightedImage
            }
        }
        configureCell(cell, indicatorInfo: indicatorInfo)
        
        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, 1, true, false)
            }
        } else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(currentIndex == indexPath.item ? nil : cell, currentIndex == indexPath.item ? cell : nil, false)
            }
        }
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        guard scrollView == containerView else { return }
        shouldUpdateButtonBarView = true
    }
    
    open func configureCell(_ cell: ButtonBarViewCellSalary, indicatorInfo: IndicatorInfo) {
    }
    
    private func calculateWidths() -> [CGFloat] {
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout // swiftlint:disable:this force_cast
        let numberOfCells = viewControllers.count
        
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        for viewController in viewControllers {
            let childController = viewController as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            let indicatorInfo = childController.indicatorInfo(for: self)
            switch buttonBarItemSpec! {
            case .cellClass(let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .nibFile(_, _, let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            }
        }
        
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if !settings.style.buttonBarItemsShouldFillAvailableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        } else {
            let stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchedCellWidthIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()
            
            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }
            
            return stretchedCellWidths
        }
    }
    
    private var shouldUpdateButtonBarView = true
    private var collectionViewDidLoad = false
    var isHomeViewDidLoad = false
    
}
