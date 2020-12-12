//
//  UIReusableViewProtocol.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-08-07.
//  Copyright © 2017 patsluth. All rights reserved.
//

import UIKit

#if os(iOS)

public protocol UIReusableViewProtocol {
	func prepareForReuse()
}

extension UITableViewCell: UIReusableViewProtocol { }

extension UICollectionReusableView: UIReusableViewProtocol { }

#endif
