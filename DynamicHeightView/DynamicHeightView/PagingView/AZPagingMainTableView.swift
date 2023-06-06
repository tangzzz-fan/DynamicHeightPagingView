//
//  AZPagingMainTableView.swift
//  SmileUI
//
//  Created by Tango on 2022/11/4.
//  Copyright © 2022 Azir. All rights reserved.
//

import UIKit

@objc public protocol AZPagingMainTableViewGestureDelegate: AnyObject {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                        shouldRecognizeSimultaneouslyWith
                                        otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

open class AZPagingMainTableView: UITableView {
    public weak var gestureDelegate: AZPagingMainTableViewGestureDelegate?
}

extension AZPagingMainTableView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureDelegate = gestureDelegate {
            // 让自己的代理去做判断, 就不需要都继承这个 tableview. 而是通过代理实现.
            return gestureDelegate.mainTableViewGestureRecognizer(gestureRecognizer,
                                                                  shouldRecognizeSimultaneouslyWith:
                                                                    otherGestureRecognizer)
        } else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
            && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        }
    }
}
