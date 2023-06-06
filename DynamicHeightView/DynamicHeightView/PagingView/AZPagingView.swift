//
//  AZPagingView.swift
//  SmileUI
//
//  Created by Tango on 2022/11/4.
//  Copyright © 2022 Azir. All rights reserved.
//

import UIKit
import Anchorage

@objc
public protocol AZPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: AZPagingView) -> CGFloat
    func tableHeaderView(in pagingView: AZPagingView) -> UIView
    func heightForPinSectionHeader(in pagingView: AZPagingView) -> Int
    func viewForPinSectionHeader(in pagingView: AZPagingView) -> UIView
    func numberOfLists(in pagingView: AZPagingView) -> Int
    func pagingView(_ pagingView: AZPagingView,
                    initListAtIndex index: Int) -> AZPagingViewListViewDelegate
    
    @objc optional func pagingView(_ pagingView: AZPagingView,
                                   mainTableViewDidScroll scrollView: UIScrollView)
    @objc optional func pagingView(_ pagingView: AZPagingView,
                                   mainTableViewWillBeginDragging scrollView: UIScrollView)
    @objc optional func pagingView(_ pagingView: AZPagingView,
                                   mainTableViewDidEndDragging scrollView: UIScrollView,
                                   willDecelerate decelerate: Bool)
    @objc optional func pagingView(_ pagingView: AZPagingView,
                                   mainTableViewDidEndDecelerating scrollView: UIScrollView)
    @objc optional func pagingView(_ pagingView: AZPagingView,
                                   mainTableViewDidEndScrollingAnimation scrollView: UIScrollView)
    
    @objc optional func scrollViewClassInListContainerView(in pagingView: AZPagingView) -> AnyClass
}

public class AZPagingView: UIView {
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            listContainerView.defaultSelectedIndex = defaultSelectedIndex
        }
    }
    
    public private(set) lazy var mainTableView = AZPagingMainTableView(frame: .zero, style: .plain)
    public private(set) lazy var listContainerView = AZPagingListContainerView(dataSource: self,
                                                                               type: listContainerType)
    public private(set) var validListDict = [Int: AZPagingViewListViewDelegate]()
    
    public var pinSectionHeaderVerticalOffset: Int = 0
    public var isListHorizontalScrollEnabled = true {
        didSet {
            listContainerView.scrollView.isScrollEnabled = isListHorizontalScrollEnabled
        }
    }
    
    // swiftlint:disable identifier_name
    public var automaticallyDisplayListVerticalScrollIndicator = true
    
    public var currentScrollingListView: UIScrollView?
    public var currentList: AZPagingViewListViewDelegate?
    private var currentIndex = 0
    private weak var delegate: AZPagingViewDelegate?
    private var tableHeaderContainerView: UIView!
    private let cellIdentifier = "cell"
    private let listContainerType: AZPagingListContainerType
    
    public init(delegate: AZPagingViewDelegate,
                listContainerType: AZPagingListContainerType = .collectionView) {
        self.delegate = delegate
        self.listContainerType = listContainerType
        super.init(frame: CGRect.zero)
        
        listContainerView.delegate = self
        
        mainTableView.backgroundColor = .clear
        mainTableView.showsVerticalScrollIndicator = false
        mainTableView.showsHorizontalScrollIndicator = false
        mainTableView.separatorStyle = .none
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.scrollsToTop = false
        refreshTableHeaderView()
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        mainTableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            mainTableView.sectionHeaderTopPadding = 0
        }
        addSubview(mainTableView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if mainTableView.frame != bounds {
            mainTableView.frame = bounds
            mainTableView.reloadData()
        }
    }
    
    open func reloadData() {
        currentList = nil
        currentScrollingListView = nil
        validListDict.removeAll()
        refreshTableHeaderView()
        
        if pinSectionHeaderVerticalOffset != 0
            && mainTableView.contentOffset.y > CGFloat(pinSectionHeaderVerticalOffset) {
            mainTableView.contentOffset = .zero
        }
        mainTableView.reloadData()
        listContainerView.reloadData()
    }
    
    open func resizeTableHeaderViewHeight(animatable: Bool = false,
                                          duration: TimeInterval = 0.25,
                                          curve: UIView.AnimationCurve = .linear) {
        guard let delegate = delegate else { return }
        if animatable {
            var options: UIView.AnimationOptions = .curveLinear
            switch curve {
            case .easeIn: options = .curveEaseIn
            case .easeOut: options = .curveEaseOut
            case .easeInOut: options = .curveEaseInOut
            default: break
            }
            var bounds = tableHeaderContainerView.bounds
            bounds.size.height = delegate.tableHeaderViewHeight(in: self)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                self.tableHeaderContainerView.frame = bounds
                self.mainTableView.tableHeaderView = self.tableHeaderContainerView
                self.mainTableView.setNeedsLayout()
                self.mainTableView.layoutIfNeeded()},
                           completion: nil)
        } else {
            var bounds = tableHeaderContainerView.bounds
            bounds.size.height = delegate.tableHeaderViewHeight(in: self)
            tableHeaderContainerView.frame = bounds
            mainTableView.tableHeaderView = tableHeaderContainerView
        }
    }
    
    open func preferredProcessListViewDidScroll(scrollView: UIScrollView) {
        if mainTableView.contentOffset.y < mainTableViewMaxContentOffsetY() {
            currentList?.listScrollViewWillResetContentOffset?()
            setListScrollViewToMinContentOffsetY(scrollView)
            if automaticallyDisplayListVerticalScrollIndicator {
                scrollView.showsVerticalScrollIndicator = false
            }
        } else {
            setMainTableViewToMaxContentOffsetY()
            if automaticallyDisplayListVerticalScrollIndicator {
                scrollView.showsVerticalScrollIndicator = true
            }
        }
    }
    
    open func preferredProcessMainTableViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentScrollingListView = currentScrollingListView else { return }
        if currentScrollingListView.contentOffset.y > minContentOffsetYInListScrollView(currentScrollingListView) {
            setMainTableViewToMaxContentOffsetY()
        }
        
        if mainTableView.contentOffset.y < mainTableViewMaxContentOffsetY() {
            for list in validListDict.values {
                list.listScrollViewWillResetContentOffset?()
                setListScrollViewToMinContentOffsetY(list.listScrollView())
            }
        }
        
        if scrollView.contentOffset.y > mainTableViewMaxContentOffsetY()
            && currentScrollingListView.contentOffset.y == minContentOffsetYInListScrollView(currentScrollingListView) {
            setMainTableViewToMaxContentOffsetY()
        }
    }
    
    // MARK: - Private
    
    func refreshTableHeaderView() {
        guard let delegate = delegate else { return }
        let tableHeaderView = delegate.tableHeaderView(in: self)
        let containerView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 0,
                                                 height: CGFloat(delegate.tableHeaderViewHeight(in: self))))
        containerView.addSubview(tableHeaderView)

        tableHeaderView.topAnchor == containerView.topAnchor
        tableHeaderView.leadingAnchor == containerView.leadingAnchor
        tableHeaderView.bottomAnchor == containerView.bottomAnchor
        tableHeaderView.trailingAnchor == containerView.trailingAnchor
        
        tableHeaderContainerView = containerView
        mainTableView.tableHeaderView = containerView
    }
    
    func adjustMainScrollViewToTargetContentInsetIfNeeded(inset: UIEdgeInsets) {
        if mainTableView.contentInset != inset {
            // 防止循环调用
            mainTableView.delegate = nil
            mainTableView.contentInset = inset
            mainTableView.delegate = self
        }
    }
    
    func isSetMainScrollViewContentInsetToZeroEnabled(scrollView: UIScrollView) -> Bool {
        return !(scrollView.contentInset.top != 0
                 && scrollView.contentInset.top != CGFloat(pinSectionHeaderVerticalOffset))
    }
    
    func mainTableViewMaxContentOffsetY() -> CGFloat {
        guard let delegate = delegate else { return 0 }
        return CGFloat(delegate.tableHeaderViewHeight(in: self)) - CGFloat(pinSectionHeaderVerticalOffset)
    }
    
    func setMainTableViewToMaxContentOffsetY() {
        mainTableView.contentOffset = CGPoint(x: 0, y: mainTableViewMaxContentOffsetY())
    }
    
    func minContentOffsetYInListScrollView(_ scrollView: UIScrollView) -> CGFloat {
        return -scrollView.adjustedContentInset.top
    }
    
    func setListScrollViewToMinContentOffsetY(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x,
                                           y: minContentOffsetYInListScrollView(scrollView))
    }
    
    func pinSectionHeaderHeight() -> CGFloat {
        guard let delegate = delegate else { return 0 }
        return CGFloat(delegate.heightForPinSectionHeader(in: self))
    }
    
    func listViewDidScroll(scrollView: UIScrollView) {
        currentScrollingListView = scrollView
        preferredProcessListViewDidScroll(scrollView: scrollView)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AZPagingView: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return max(bounds.height - pinSectionHeaderHeight() - CGFloat(pinSectionHeaderVerticalOffset), 0)
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        if listContainerView.superview != cell.contentView {
            cell.contentView.addSubview(listContainerView)
        }
        if listContainerView.frame != cell.bounds {
            listContainerView.frame = cell.bounds
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return pinSectionHeaderHeight()
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let delegate = delegate else { return nil }
        return delegate.viewForPinSectionHeader(in: self)
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect.zero)
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    // swiftlint:disable force_unwrapping
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if pinSectionHeaderVerticalOffset != 0 {
            if !(currentScrollingListView != nil
                 && currentScrollingListView!.contentOffset.y
                 > minContentOffsetYInListScrollView(currentScrollingListView!)) {
                if scrollView.contentOffset.y >= CGFloat(pinSectionHeaderVerticalOffset) {
                    let inset = UIEdgeInsets(top: CGFloat(pinSectionHeaderVerticalOffset),
                                             left: 0,
                                             bottom: 0,
                                             right: 0)
                    adjustMainScrollViewToTargetContentInsetIfNeeded(inset: inset)
                } else {
                    if isSetMainScrollViewContentInsetToZeroEnabled(scrollView: scrollView) {
                        adjustMainScrollViewToTargetContentInsetIfNeeded(inset: UIEdgeInsets.zero)
                    }
                }
            }
        }
        preferredProcessMainTableViewDidScroll(scrollView)
        delegate?.pagingView?(self, mainTableViewDidScroll: scrollView)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        listContainerView.scrollView.isScrollEnabled = false
        delegate?.pagingView?(self, mainTableViewWillBeginDragging: scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isListHorizontalScrollEnabled && !decelerate {
            listContainerView.scrollView.isScrollEnabled = true
        }
        delegate?.pagingView?(self, mainTableViewDidEndDragging: scrollView, willDecelerate: decelerate)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isListHorizontalScrollEnabled {
            listContainerView.scrollView.isScrollEnabled = true
        }
        if isSetMainScrollViewContentInsetToZeroEnabled(scrollView: scrollView) {
            if mainTableView.contentInset.top != 0 && pinSectionHeaderVerticalOffset != 0 {
                adjustMainScrollViewToTargetContentInsetIfNeeded(inset: UIEdgeInsets.zero)
            }
        }
        delegate?.pagingView?(self, mainTableViewDidEndDecelerating: scrollView)
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isListHorizontalScrollEnabled {
            listContainerView.scrollView.isScrollEnabled = true
        }
        delegate?.pagingView?(self, mainTableViewDidEndScrollingAnimation: scrollView)
    }
}

extension AZPagingView: AZPagingListContainerViewDataSource {
    public func numberOfLists(in listContainerView: AZPagingListContainerView) -> Int {
        guard let delegate = delegate else { return 0 }
        return delegate.numberOfLists(in: self)
    }
    
    // swiftlint:disable force_unwrapping
    public func listContainerView(_ listContainerView: AZPagingListContainerView,
                                  initListAt index: Int) -> AZPagingViewListViewDelegate {
        guard let delegate = delegate else { fatalError("AZPaingView.delegate must not be nil") }
        var list = validListDict[index]
        if list == nil {
            list = delegate.pagingView(self, initListAtIndex: index)
            list?.listViewDidScrollCallback {[weak self, weak list] (scrollView) in
                self?.currentList = list
                self?.listViewDidScroll(scrollView: scrollView)
            }
            validListDict[index] = list!
        }
        return list!
    }
    
    public func scrollViewClass(in listContainerView: AZPagingListContainerView) -> AnyClass {
        if let any = delegate?.scrollViewClassInListContainerView?(in: self) {
            return any
        }
        return UIView.self
    }
}

extension AZPagingView: AZPagingListContainerViewDelegate {
    public func listContainerViewWillBeginDragging(_ listContainerView: AZPagingListContainerView) {
        mainTableView.isScrollEnabled = false
    }
    
    public func listContainerViewDidEndScrolling(_ listContainerView: AZPagingListContainerView) {
        mainTableView.isScrollEnabled = true
    }
    
    public func listContainerView(_ listContainerView: AZPagingListContainerView, listDidAppearAt index: Int) {
        currentScrollingListView = validListDict[index]?.listScrollView()
        for listItem in validListDict.values {
            if listItem === validListDict[index] {
                listItem.listScrollView().scrollsToTop = true
            } else {
                listItem.listScrollView().scrollsToTop = false
            }
        }
    }
}
