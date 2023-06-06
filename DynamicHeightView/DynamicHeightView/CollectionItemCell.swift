//
//  CollectionItemCell.swift
//  DynamicHeightView
//
//  Created by Tango on 2023/6/6.
//

import UIKit
import Anchorage

class CollectionItemCell: UICollectionViewCell {
    
    struct LayoutConstants {
        static let vSpacing: CGFloat = 8
        static let hSpacing: CGFloat = 8
        static let titleHeight: CGFloat = 20
        static let nickNameHeight: CGFloat = 18
        static let minSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 10
        static let lineSpacing: CGFloat = 4.0
        static let lineHeight: CGFloat = 18.0
        static let avatorSize = CGSize(width: 20, height: 20)
        static let buttonHeight: CGFloat = 20
        static let bottomLeftMaxWidth: CGFloat = 120
        static let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private lazy var containerView = {
        let view = UIView(frame: .zero)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = LayoutConstants.cornerRadius
        view.backgroundColor = .white
        return view
    }()

    private lazy var contentImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel = {
        let label = UILabel(frame: .zero)
        label.text = "这是 title"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var textLabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 4
        label.text = "这是 text"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var avatorImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.sizeAnchors == LayoutConstants.avatorSize
        imageView.layer.cornerRadius = LayoutConstants.avatorSize.width / 2
        return imageView
    }()
    
    private lazy var nickNameLabel = {
        let label = UILabel(frame: .zero)
        label.text = "这是 nickname"
        label.textColor = .black
        return label
    }()
    
    private lazy var userInfoSV = {
        let sv = UIStackView(arrangedSubviews: [avatorImageView, nickNameLabel])
        sv.axis = .horizontal
        sv.spacing = LayoutConstants.vSpacing / 2
        return sv
    }()
    
    private lazy var glossaryNameLabel = {
        let label = UILabel(frame: .zero)
        label.text = "这是 glossary name"
        label.textColor = .black
        return label
    }()
    
    private lazy var bottomLeftSV = {
        let sv = UIStackView(arrangedSubviews: [userInfoSV, glossaryNameLabel])
        sv.axis = .horizontal
        return sv
    }()
    
    private lazy var commentButton = {
        let button = UIButton(frame: .zero)
        button.heightAnchor == LayoutConstants.buttonHeight
        button.setTitle("评论", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    private lazy var likeButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("点赞", for: .normal)
        button.heightAnchor == LayoutConstants.buttonHeight
        button.setTitleColor(.lightGray, for: .normal)
        return button
    }()
    
    private lazy var bottomRightSV = {
        let sv = UIStackView(arrangedSubviews: [commentButton, likeButton])
        sv.axis = .horizontal
        return sv
    }()
    private lazy var bottomSV = {
        let sv = UIStackView(arrangedSubviews: [bottomLeftSV, bottomRightSV])
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        return sv
    }()
    private lazy var bottomCenterSV = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textLabel, bottomSV])
        sv.axis = .vertical
        sv.spacing = LayoutConstants.vSpacing
        return sv
    }()
    private lazy var contentSV = {
        let sv = UIStackView(arrangedSubviews: [contentImageView, bottomCenterSV])
        sv.axis = .vertical
        sv.spacing = LayoutConstants.vSpacing
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(contentSV)
        setupLayout()
    }
    
    private func setupLayout() {
        containerView.edgeAnchors == contentView.edgeAnchors
        contentSV.edgeAnchors == containerView.edgeAnchors + LayoutConstants.insets
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.image = nil
    }
}
