//
//  ViewController.swift
//  DynamicHeightView
//
//  Created by Tango on 2023/4/17.
//

import UIKit
import Anchorage
import JXSegmentedView

class ViewController: UIViewController {
    
    private struct LayoutConstants {
        static let columsOfSingleHeight: CGFloat = 132
        static let columsOfTwoHeight: CGFloat = 168
        static let heightForHeaderInSection: Int = 44
        static let segmentedHeight: CGFloat = 44
    }
    
    var pagingView: AZPagingView!
    var headerHeight = 100.0
    
    private lazy var segmentedView: JXSegmentedView = {
        JXSegmentedView(frame: CGRect(x: 0, y: 0,
                                      width: UIScreen.main.bounds.size.width,
                                      height: CGFloat(LayoutConstants.segmentedHeight)))
    }()
    
    private lazy var headerView: HeaderView = {
        let headerView = HeaderView(frame: .zero)
        headerView.backgroundColor = .random
        return headerView
    }()
    
    private var segmentDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titles = ["优质回复", "新问题", "好问题", "待回复"]
        dataSource.titleSelectedColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        dataSource.titleNormalColor = UIColor.black
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = true
        dataSource.isItemSpacingAverageEnabled = false
        return dataSource
    }()
    
    private var childViews: [SegmentBaseListView] = {
        var childViews = [SegmentBaseListView]()
        for _ in 0..<4 {
            let view = SegmentBaseListView()
            view.backgroundColor = .random
            childViews.append(view)
        }
        return childViews
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedView()
        setupLayout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            // 当header view 部分的数据返回时, 执行刷新
            self?.headerView.updateDescription()
            let height = self?.headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            self?.headerHeight = height ?? 200.0
            self?.pagingView.resizeTableHeaderViewHeight(animatable: true)
        }
    }
    
    private func setupSegmentedView() {
        segmentedView.backgroundColor = UIColor.white
        segmentedView.dataSource = segmentDataSource
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        lineView.indicatorWidth = 30
        segmentedView.indicators = [lineView]
        
        let lineWidth = 1 / UIScreen.main.scale
        let lineLayer = CALayer()
        lineLayer.backgroundColor = UIColor.lightGray.cgColor
        lineLayer.frame = CGRect(x: 0,
                                 y: segmentedView.bounds.height - lineWidth,
                                 width: segmentedView.bounds.width,
                                 height: lineWidth)
        segmentedView.layer.addSublayer(lineLayer)
        
        pagingView = AZPagingView(delegate: self)
        
        view.addSubview(pagingView)
        
        segmentedView.listContainer = pagingView.listContainerView
    }
    
    private func setupLayout() {
        pagingView.topAnchor == view.topAnchor + 88
        pagingView.leadingAnchor == view.leadingAnchor
        pagingView.trailingAnchor == view.trailingAnchor
        pagingView.bottomAnchor == view.bottomAnchor
    }
}

extension ViewController: AZPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: AZPagingView) -> CGFloat {
        return headerHeight
    }
    
    func tableHeaderView(in pagingView: AZPagingView) -> UIView {
        return headerView
    }
    
    func heightForPinSectionHeader(in pagingView: AZPagingView) -> Int {
        return LayoutConstants.heightForHeaderInSection
    }
    
    func viewForPinSectionHeader(in pagingView: AZPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: AZPagingView) -> Int {
        return segmentDataSource.titles.count
    }
    
    func pagingView(_ pagingView: AZPagingView, initListAtIndex index: Int) -> AZPagingViewListViewDelegate {
        let childVC = childViews[index]
        return childVC
    }
    
    func pagingView(_ pagingView: AZPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
        
    }
}

extension AZPagingListContainerView: JXSegmentedViewListContainer {}
