//
//  HeaderView.swift
//  DynamicHeightView
//
//  Created by Tango on 2023/6/6.
//

import UIKit
import Anchorage

class HeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureLayout()
        
        print("dddddd 正在执行 HeaderView 创建")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        addSubview(contentSV)
        contentSV.edgeAnchors == edgeAnchors + UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    public func updateDescription() {
        textLabel.isHidden = false
    }
    
    lazy var groupIcon: UIImageView = {
        let icon = UIImage(named: "avator")
        let imageView = UIImageView(image: icon)
        imageView.sizeAnchors == CGSize(width: 60, height: 60)
        return imageView
    }()
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.text = "数一基础过关660题群"
        return title
    }()
    
    lazy var groupCount: UIButton = {
        let count = UIButton()
        count.setTitle("群人数: 5", for: .normal)
        return count
    }()
    
    lazy var spacingCount: UILabel = {
        let spacing = UILabel()
        spacing.text = "500人群"
        return spacing
    }()
    
    lazy var bottomSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupCount, spacingCount])
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        sv.spacing = 10
        return sv
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.isHidden = true
        label.text = "这是测试数据, 这是测试数据, 这是测试数据, 这是测试数据,这是测试数据, 这是测试数据, 这是测试数据, 这是测试数据,这是测试数据, 这是测试数据, 这是测试数据, 这是测试数据, 这是测试数据, 这是测试数据,这是测试数据, 这是测试数据,"
        return label
    }()
    
    lazy var rightSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [title, bottomSV, textLabel])
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        sv.spacing = 10
        return sv
    }()
    
    lazy var contentSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupIcon, rightSV])
        sv.axis = .horizontal
        sv.alignment = .leading
        sv.distribution = .fillProportionally
        sv.spacing = 10
        return sv
    }()
}
