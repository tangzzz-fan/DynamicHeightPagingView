//
//  SegmentBaseListView.swift
//  DynamicHeightView
//
//  Created by Tango on 2023/6/6.
//

import UIKit
import Anchorage
import JXSegmentedView

class SegmentBaseListView: UIView {
    private struct LayoutConstants {
        static let refreshControlHeight: CGFloat = 64.0
        static let hSpacing: CGFloat = 8
        static let sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        static let imageWidth = (UIScreen.main.bounds.width - hSpacing * 7) / 2
    }
    
    var listViewDidScrollCallback: ((UIScrollView) -> Void)?

    private var collectionView: UICollectionView!

    init() {
        super.init(frame: .zero)

        setupCollectionView()
        setupViewHierarchy()
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2
        layout.itemRenderDirection = .shortestFirst
        layout.sectionInset = LayoutConstants.sectionInset
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionItemCell.self, forCellWithReuseIdentifier: "CollectionItemCell")
        self.collectionView = collectionView
    }
    
    private func setupViewHierarchy() {
        addSubview(collectionView)
        collectionView.edgeAnchors == edgeAnchors
    }
    
    private func setupStyle() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
    }
    
}

extension SegmentBaseListView: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionItemCell", for: indexPath)
        cell.backgroundColor = .systemPink
        return cell
    }
}

extension SegmentBaseListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension SegmentBaseListView: CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: LayoutConstants.imageWidth,
                      height: LayoutConstants.imageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        columnCountFor section: Int) -> Int {
        return 1
    }
}

extension SegmentBaseListView: AZPagingViewListViewDelegate {
    public func listView() -> UIView {
        return self
    }
    
    public func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> Void) {
        self.listViewDidScrollCallback = callback
    }

    public func listScrollView() -> UIScrollView {
        return self.collectionView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        listViewDidScrollCallback?(scrollView)
    }
}

extension SegmentBaseListView: JXSegmentedListContainerViewListDelegate {}

