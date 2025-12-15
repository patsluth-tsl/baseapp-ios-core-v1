//
//  FilePreviewController.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Foundation
import QuickLook
import UIKit

internal class FilePreviewControllerLegacy: QLPreviewController {
	private weak var childNavigationController: UINavigationController? {
		didSet {
			teardownKVOFor(navigationController: oldValue)
			setupKVOFor(navigationController: childNavigationController)
			updateAppearance(navigationController: childNavigationController)
		}
	}
	private var kvoContext = 0
	
	public override var prefersStatusBarHidden: Bool {
		return true
	}
    
    
	deinit {
		teardownKVOFor(navigationController: childNavigationController)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	override func addChild(_ childController: UIViewController) {
		super.addChild(childController)
		
		if let navigationController = childController as? UINavigationController {
			childNavigationController = navigationController
		}
	}
    
    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let navigationController = object as? UINavigationController else { return }
        
        teardownKVOFor(navigationController: navigationController)
        updateAppearance(navigationController: navigationController)
        setupKVOFor(navigationController: navigationController)
    }
	
    fileprivate func setupKVOFor(navigationController nc: UINavigationController?) {
        nc?.addObserver(self,
                        forKeyPath: "navigationBar.barTintColor",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
        nc?.addObserver(self,
                        forKeyPath: "navigationBar.tintColor",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
        nc?.addObserver(self,
                        forKeyPath: "navigationBar.translucent",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
        nc?.addObserver(self,
                        forKeyPath: "toolbar.barTintColor",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
        nc?.addObserver(self,
                        forKeyPath: "toolbar.tintColor",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
        nc?.addObserver(self,
                        forKeyPath: "toolbar.translucent",
                        options: NSKeyValueObservingOptions.new,
                        context: &self.kvoContext)
    }
	
	fileprivate func teardownKVOFor(navigationController nc: UINavigationController?) {
        nc?.removeObserver(self,
                           forKeyPath: "navigationBar.barTintColor",
                           context: &self.kvoContext)
        nc?.removeObserver(self,
                           forKeyPath: "navigationBar.tintColor",
                           context: &self.kvoContext)
        nc?.removeObserver(self,
                           forKeyPath: "navigationBar.translucent",
                           context: &self.kvoContext)
        nc?.removeObserver(self,
                           forKeyPath: "toolbar.barTintColor",
                           context: &self.kvoContext)
        nc?.removeObserver(self,
                           forKeyPath: "toolbar.tintColor",
                           context: &self.kvoContext)
        nc?.removeObserver(self,
                           forKeyPath: "toolbar.translucent",
                           context: &self.kvoContext)
	}
	
	private func updateAppearance(navigationController: UINavigationController?) {
		guard let delegate = self.delegate as? FilePreviewerDelegate else { return }
		
//		if let styleProvider = delegate.previewController(self, styleProviderType: UINavigationBar.self) {
//			let navigationBar = navigationController?.navigationBar
//			navigationBar?.barTintColor = styleProvider.barTintColor
//			navigationBar?.tintColor = styleProvider.tintColor
//			navigationBar?.isTranslucent = styleProvider.isTranslucent
//		}
//		
//		if let styleProvider = delegate.previewController(self, styleProviderType: UIToolbar.self) {
//			let toolbar = navigationController?.toolbar
//			toolbar?.barTintColor = styleProvider.barTintColor
//			toolbar?.tintColor = styleProvider.tintColor
//			toolbar?.isTranslucent = styleProvider.isTranslucent
//		}
		
		
//		navigationController?.navigationBar.barTintColor = UINavigationBar.appearance().barTintColor
//		navigationController?.navigationBar.tintColor = UINavigationBar.appearance().tintColor
//		navigationController?.navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
//
//		navigationController?.toolbar.barTintColor = UIToolbar.appearance().barTintColor
//		navigationController?.toolbar.tintColor = UIToolbar.appearance().tintColor
//		navigationController?.toolbar.isTranslucent = UINavigationBar.appearance().isTranslucent
	}
}
