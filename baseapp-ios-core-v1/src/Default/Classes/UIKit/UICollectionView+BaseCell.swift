//
//  UICollectionView+BaseCell.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-08-07.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

#if os(iOS)

import RxCocoa
import RxSwift
import UIKit

extension UICollectionView {
    open class BaseCell: UICollectionViewCell {
        public private(set) var disposeBag = DisposeBag()
        
        open override func prepareForReuse() {
            disposeBag = DisposeBag()
            
            super.prepareForReuse()
        }
    }
}

#endif
