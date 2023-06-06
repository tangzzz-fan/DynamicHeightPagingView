//
//  AZPagingListContainerScrollView.swift
//  SmileUI
//
//  Created by Tango on 2022/11/4.
//  Copyright © 2022 Azir. All rights reserved.
//
// swiftlint:disable force_cast force_unwrapping

import UIKit

class AZPagingListContainerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    var isCategoryNestPagingEnabled = false
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isCategoryNestPagingEnabled,
           let panGestureClass = NSClassFromString("UIScrollViewPanGestureRecognizer"),
           gestureRecognizer.isMember(of: panGestureClass) {
            
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let velocityX = panGesture.velocity(in: panGesture.view!).x
            if velocityX > 0 {
                if contentOffset.x == 0 {
                    return false
                }
            } else if velocityX < 0 {
                if contentOffset.x + bounds.size.width == contentSize.width {
                    return false
                }
            }
        }
        return true
    }
}

class AZPagingListContainerCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    var isCategoryNestPagingEnabled = false
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isCategoryNestPagingEnabled,
           let panGestureClass = NSClassFromString("UIScrollViewPanGestureRecognizer"),
           gestureRecognizer.isMember(of: panGestureClass) {
            
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let velocityX = panGesture.velocity(in: panGesture.view!).x
            if velocityX > 0 {
                if contentOffset.x == 0 {
                    return false
                }
            } else if velocityX < 0 {
                if contentOffset.x + bounds.size.width == contentSize.width {
                    return false
                }
            }
        }
        return true
    }
}
