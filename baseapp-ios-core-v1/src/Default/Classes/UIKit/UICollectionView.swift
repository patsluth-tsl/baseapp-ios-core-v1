//
//  UICollectionView.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-19.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation

#if os(iOS)

public extension UICollectionView {
    func lastIndexPath(inSection section: Int? = nil) -> IndexPath? {
        let section = section ?? numberOfSections - 1
        let item = numberOfItems(inSection: section) - 1
        
        return IndexPath(item: item, section: section)
    }
}

public extension UICollectionView {
    func registerCell<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionViewCell {
        register(type, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func registerCell<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionViewCell & UINib.Provider {
        registerCell(type, nib: T.nib)
    }
    
    func registerCell<T>(
        _ type: T.Type,
        nib: UINib?,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionViewCell {
        register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func registerSupplementary<T>(
        _ type: T.Type,
        kind: String,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionReusableView {
        register(type,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: reuseIdentifier)
    }
    
    func registerSupplementary<T>(
        _ type: T.Type,
        kind: String,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionViewCell & UINib.Provider {
        registerSupplementary(type, nib: T.nib, kind: kind)
    }
    
    func registerSupplementary<T>(
        _ type: T.Type,
        nib: UINib?,
        kind: String,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionReusableView {
        register(nib,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: reuseIdentifier)
    }
    
    /// Wrapper for registerSupplementary kind UICollectionView.elementKindSectionHeader
    func registerHeader<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UICollectionReusableView {
        registerSupplementary(type,
                              kind: UICollectionView.elementKindSectionHeader,
                              reuseIdentifier: reuseIdentifier)
    }
    
    /// Wrapper for registerSupplementary kind UICollectionView.elementKindSectionFooter
    func registerFooter<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)") where T: UICollectionReusableView {
        registerSupplementary(type,
                              kind: UICollectionView.elementKindSectionFooter,
                              reuseIdentifier: reuseIdentifier)
    }
    
    func dequeue<T>(
        _ type: T.Type,
        for indexPath: IndexPath,
        reuseIdentifier: String = "\(T.self)",
        _ configure: ((T) -> Void)? = nil
    ) -> T where T: UICollectionViewCell {
        // swiftlint:disable:next force_cast
        let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! T
        configure?(cell)
        return cell
    }
    
    func dequeueSupplementary<T>(
        _ type: T.Type,
        kind: String,
        for indexPath: IndexPath,
        reuseIdentifier: String = "\(T.self)",
        _ configure: ((T) -> Void)? = nil
    ) -> T where T: UICollectionReusableView {
        let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
            // swiftlint:disable:next force_cast
        ) as! T
        configure?(view)
        return view
    }
    
    func cell<T>(
        _ type: T.Type,
        at indexPath: IndexPath
    ) -> T? where T: UICollectionViewCell {
        return cellForItem(at: indexPath) as? T
    }
}

public extension UICollectionView {
    fileprivate var prototypeCells: [String: UICollectionViewCell] {
        get {
            return get(associatedObject: "prototypeCells", [String: UICollectionViewCell].self) ?? [:]
        }
        set {
            set(associatedObject: "prototypeCells", object: newValue)
        }
    }
    
    func prototype<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) -> T where T: UICollectionViewCell {
        if let cell = prototypeCells[reuseIdentifier] as? T {
            return cell
        }
        
        return T.make({
            self.prototypeCells[reuseIdentifier] = $0
        })
    }
}

#endif
