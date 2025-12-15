//
//  UITableView.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-19.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import ObjectiveC

#if os(iOS)

public extension UITableView {
    func lastIndexPath(inSection section: Int? = nil) -> IndexPath? {
        let section = section ?? numberOfSections - 1
        let row = numberOfRows(inSection: section) - 1
        
        return IndexPath(row: row, section: section)
    }
}

public extension UITableView {
    func registerCell<T>(
        _ type: T.Type,
        nib: UINib?,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewCell {
        register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func registerCell<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewCell & UINib.Provider {
        registerCell(type, nib: T.nib)
    }
    
    func registerCell<T>(
        _  type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewCell {
        register(T.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func registerHeaderFooter<T>(
        _ type: T.Type,
        nib: UINib?,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewHeaderFooterView {
        register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    func registerHeaderFooter<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewHeaderFooterView & UINib.Provider {
        registerHeaderFooter(type, nib: T.nib)
    }
    
    func registerHeaderFooter<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) where T: UITableViewHeaderFooterView {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
    
    func dequeue<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)",
        _ configure: ((T) -> Void)? = nil
    ) -> T? where T: UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: reuseIdentifier) as? T
        if let cell = cell {
            configure?(cell)
        }
        return cell
    }
    
    func dequeue<T>(
        _ type: T.Type,
        for indexPath: IndexPath,
        reuseIdentifier: String = "\(T.self)",
        _ configure: ((T) -> Void)? = nil
    ) -> T where T: UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! T
        configure?(cell)
        return cell
    }
    
    func dequeueHeaderFooter<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) -> T? where T: UITableViewHeaderFooterView {
        return dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? T
    }
    
    func cell<T>(
        _ type: T.Type,
        at indexPath: IndexPath
    ) -> T? where T: UITableViewCell {
        return cellForRow(at: indexPath) as? T
    }
}

public extension UITableView {
    fileprivate var prototypeCells: [String: UITableViewCell] {
        get {
            return get(associatedObject: "prototypeCells", [String: UITableViewCell].self) ?? [:]
        }
        set {
            set(associatedObject: "prototypeCells", object: newValue)
        }
    }
    
    func prototype(reuseIdentifier: String) -> UITableViewCell? {
        if let cell = prototypeCells[reuseIdentifier] {
            return cell
        }
        
        let cell = dequeueReusableCell(withIdentifier: reuseIdentifier)
        prototypeCells[reuseIdentifier] = cell
        
        return cell
    }
    
    func prototype<T>(
        _ type: T.Type,
        reuseIdentifier: String = "\(T.self)"
    ) -> T where T: UITableViewCell {
        if let cell = prototype(reuseIdentifier: reuseIdentifier) as? T {
            return cell
        }
        
        return T.make({
            self.prototypeCells[reuseIdentifier] = $0
        })
    }
}

#endif
