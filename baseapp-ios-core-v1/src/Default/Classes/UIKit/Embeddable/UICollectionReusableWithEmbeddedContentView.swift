//
//  UICollectionReusableWithEmbeddedContentView.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2019-03-01.
//  Copyright © 2019 SilverLogic. All rights reserved.
//

#if os(iOS)

import SnapKit
import UIKit

public extension NSObjectProtocol where Self: UIView {
    typealias CVReusableView = UICollectionReusableWithEmbeddedContentView<Self>
}

// swiftlint:disable:next type_name
open class UICollectionReusableWithEmbeddedContentView<T>: UICollectionView.BaseReusableView, UIViewWithEmbeddedContent where T: UIView {
	public typealias Embedded = T
	public typealias PreferredLayoutAttributesProvider = (UICollectionReusableWithEmbeddedContentView<T>, UICollectionViewLayoutAttributes) -> Void
    
    public private(set) var embedded: T!
	private var preferredLayoutAttributesProvider: PreferredLayoutAttributesProvider? = nil
    
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		embedded = T.make({
			self.addSubview($0)
		}).make(constraints: {
			$0.edges.equalTo(self.snp.margins)
		})
		
		backgroundColor = nil
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	@discardableResult
	public func preferredLayoutAttributes(provider: @escaping PreferredLayoutAttributesProvider) -> Self {
		preferredLayoutAttributesProvider = provider
		return self
	}
	
	public override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
		let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
		
		//		let size = self.contentView.systemSize(fitting: attributes.size)
		//		let size = self.contentView.systemSize(horizontal: .required, vertical: .required)
		//		attributes.size = size
		
		preferredLayoutAttributesProvider?(self, attributes)
		
		return attributes
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		
		preferredLayoutAttributesProvider = nil
		(embedded as? UIReusableViewProtocol)?.prepareForReuse()
	}
	
	public override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		embedded.prepareForInterfaceBuilder()
	}
}

#endif
