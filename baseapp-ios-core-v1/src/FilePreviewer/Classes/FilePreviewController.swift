//
//  FilePreviewController.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

import Alertift
import Foundation
import PDFKit
import QuickLook
import UIKit

@available(iOS 11.0, *)
// swiftlint:disable:next type_body_length
internal class FilePreviewController: UIViewController {
    fileprivate enum SegueIdentifiers: String {
        case FileSelectionViewController
    }
    
    var fileURLs: [URL]!
    var currentPreviewItemIndex: Int = NSNotFound {
        didSet {
            navigationItem.title = nil
            
//            let numberOfPreviewItems = qlDataSource?.numberOfPreviewItems(in: qlPreviewController) ?? 0
//            guard (0..<numberOfPreviewItems).contains(currentPreviewItemIndex) else { return }
//            let previewItem = qlDataSource?.previewController(
//                qlPreviewController,
//                previewItemAt: currentPreviewItemIndex
//            )
//            guard let fileURL = previewItem as? URL else { return }
            
            guard let fileURL = fileURLs[safe: currentPreviewItemIndex] else { return }
            
            var title = fileURL.fileName
            if fileURLs.count > 1 {
                title = "\(currentPreviewItemIndex + 1) of \(fileURLs.count)"
            }
            navigationItem.title = title
        }
    }
    
    private var documentInteractionController: UIDocumentInteractionController? = nil
    
    private var pageViewController: UIPageViewController! {
        didSet {
            oldValue?.dataSource = nil
            oldValue?.delegate = nil
            
            guard let pageViewController = pageViewController else { return }
            
            pageViewController.dataSource = self
            pageViewController.delegate = self
            
            if let firstViewController = fileViewControllerFor(index: currentPreviewItemIndex) {
                pageViewController.setViewControllers(
                    [firstViewController],
                    direction: UIPageViewController.NavigationDirection.forward,
                    animated: false,
                    completion: nil
                )
            } else {
                Alertift.alert(title: "Error", message: "Failed to initialize preview")
                    .action(.default("OK"))
                    .finally({ _, _, _ in
                        self.dismiss(animated: true, completion: nil)
                    })
                    .show(on: self)
            }
        }
    }
    
    fileprivate var fileViewControllers = [FileViewController]()
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    
    
    
    
//    class func present<T: UIViewController>(
//        from: T, initialIndexPath: IndexPath
//    ) where T: FilePreviewerDataSource, T: FilePreviewerDelegate {
//        let bundle = Bundle(for: self.classForCoder())
//        let storyboard = UIStoryboard(name: "FilePreviewer", bundle: bundle)
//        // swiftlint:disable:next force_cast
//        let filePreviewController = storyboard.instantiateInitialViewController() as! FilePreviewController
//
//        filePreviewController.qlDataSource = from
//        filePreviewController.qlDelegate = from
//        filePreviewController.qlPreviewController.section = initialIndexPath.section
//        filePreviewController.currentPreviewItemIndex = initialIndexPath.item
//
//        filePreviewController.loadViewIfNeeded()
//
//        let navigationController = UINavigationController(rootViewController: filePreviewController)
//        navigationController.hidesBarsOnTap = false
//        navigationController.hidesBarsOnSwipe = false
//        navigationController.setNavigationBarHidden(false, animated: false)
//        navigationController.setToolbarHidden(false, animated: false)
//        navigationController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
//
//        from.present(navigationController, animated: true, completion: nil)
//    }
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let transitionStyle = UIPageViewController.TransitionStyle.scroll
        let navigationOrientation = UIPageViewController.NavigationOrientation.horizontal
        let pageViewController = UIPageViewController(transitionStyle: transitionStyle,
                                                      navigationOrientation: navigationOrientation,
                                                      options: nil)
        pageViewController.embedIn(parent: self, superview: view)
        pageViewController.view.make(constraints: {
            $0.edges.equalTo(self.view)
        })
        
        self.pageViewController = pageViewController
    }
    
    deinit {
//        qlPreviewController = nil
        fileViewControllers.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        guard let segueIdentifier = SegueIdentifiers(rawValue: identifier) else { return }
        
        switch segueIdentifier {
        case SegueIdentifiers.FileSelectionViewController:
            guard let destination = segue.destination as? UINavigationController else { return }
            guard let viewController = destination.topViewController as? FileSelectionViewController else { return }
//            guard let qlDataSource = qlDataSource else { return }
            
//            var fileURLs = [URL]()
//            for i in stride(from: 0,
//                            to: qlDataSource.numberOfPreviewItems(in: qlPreviewController),
//                            by: 1
//                ) {
//                    let previewItem = qlDataSource.previewController(qlPreviewController, previewItemAt: i)
//                    let fileURL = previewItem as? URL ?? URL(fileURLWithPath: "")
//                    fileURLs.append(fileURL)
//            }
            
            viewController.delegate = self
            viewController.fileURLs = fileURLs
            viewController.initialPreviewItemIndex = self.currentPreviewItemIndex
            if let barButtonItem = sender as? UIBarButtonItem {
                destination.popoverPresentationController?.barButtonItem = barButtonItem
            }
        }
    }
}

@available(iOS 11.0, *)
private extension FilePreviewController {
    @IBAction func actionButtonClicked(_ sender: UIBarButtonItem) {
//        let previewItem = qlDataSource?.previewController(
//            qlPreviewController,
//            previewItemAt: self.currentPreviewItemIndex
//        )
//        guard let fileURL = previewItem as? URL else { return }
        
        guard let fileURL = fileURLs[safe: currentPreviewItemIndex] else { return }
        
        let documentInteractionController = UIDocumentInteractionController(url: fileURL)
        documentInteractionController.delegate = self
        documentInteractionController.presentOptionsMenu(from: sender, animated: true)
        self.documentInteractionController = documentInteractionController
    }
    
    @IBAction func doneButtonClicked(_ sender: UIBarButtonItem) {
//        qlDelegate?.previewControllerWillDismiss?(qlPreviewController)
        
        dismiss(animated: true, completion: {
//            self.qlDelegate?.previewControllerDidDismiss?(self.qlPreviewController)
        })
    }
    
    @IBAction func documentSelectionButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(
            withIdentifier: SegueIdentifiers.FileSelectionViewController.rawValue,
            sender: sender
        )
    }
}

@available(iOS 11.0, *)
extension FilePreviewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(
        _ controller: UIDocumentInteractionController
    ) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(
        _ controller: UIDocumentInteractionController
    ) {
        documentInteractionController = nil
    }
}


@available(iOS 11.0, *)
private extension FilePreviewController {
    func fileViewControllerFor(index: Int) -> FileViewController? {
//        let numberOfPreviewItems = qlDataSource?.numberOfPreviewItems(in: qlPreviewController) ?? 0
//        guard (0..<numberOfPreviewItems).contains(index) else { return nil }
//        let previewItem = qlDataSource?.previewController(qlPreviewController, previewItemAt: index)
//        guard let fileURL = previewItem as? URL else { return nil }
        
        guard let fileURL = fileURLs[safe: index] else { return nil }
//
//        var fileViewController: FileViewController! = nil
        
//        if let index = fileViewControllers.index(where: { _fileViewController -> Bool in
//            guard _fileViewController.parent == nil else { return false }
//            let classStringA = String(describing: _fileViewController.classForCoder)
//            let classStringB = FileViewController.viewControllerClassStringFor(fileURL: fileURL)
//            return (classStringA == classStringB)
//        }) {
//            fileViewController = fileViewControllers[index]
//        } else {
//            fileViewController = FileViewController.createViewControllerFor(fileURL: fileURL)
//            print("Creating new", String(describing: fileViewController.classForCoder))
//            //            self.fileViewControllers.append(fileViewController)
//        }
        
//        fileViewController.view.tag = index
//        fileViewController.fileURL = fileURL
        
        return FileViewController.createViewControllerFor(fileURL: fileURL)
//        let f = FileViewController.createViewControllerFor(fileURL: fileURL)
//        f.loadViewIfNeeded()
//        f.view.tag = index
//        return f
//        return FileViewController.make({
//            $0.fileURL = fileURL
//        })
    }
}

@available(iOS 11.0, *)
extension FilePreviewController: FileSelectionViewControllerDelegate {
    func fileSelectionViewController(
        _ viewController: FileSelectionViewController,
        didSelectItemAt index: Int
    ) {
        defer {
            viewController.dismiss(animated: true, completion: nil)
        }
        
        guard currentPreviewItemIndex != index else { return }
        guard let pdfViewController = fileViewControllerFor(index: index) else { return }
        
        pageViewController.setViewControllers(
            [pdfViewController],
            direction: UIPageViewController.NavigationDirection.forward,
            animated: false,
            completion: { finished in
                if finished {
                    self.currentPreviewItemIndex = index
                }
        })
    }
}


@available(iOS 11.0, *)
extension FilePreviewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? FileViewController else { return nil }
        guard let index = fileURLs.firstIndex(of: viewController.fileURL) else { return nil }
        return fileViewControllerFor(index: index - 1)
//        return fileViewControllerFor(index: viewController.view.tag - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? FileViewController else { return nil }
        guard let index = fileURLs.firstIndex(of: viewController.fileURL) else { return nil }
        return fileViewControllerFor(index: index + 1)
//        return fileViewControllerFor(index: viewController.view.tag + 1)
    }
}


@available(iOS 11.0, *)
extension FilePreviewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        //        for pendingViewController in pendingViewControllers {
        //            pendingViewController.viewWillAppear(false)
        //        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }
        
        guard let viewController = pageViewController.viewControllers?
            .first as? FileViewController else { return }
        guard let index = fileURLs.firstIndex(of: viewController.fileURL) else { return }
        currentPreviewItemIndex = index
//        currentPreviewItemIndex = fileViewController.view.tag
    }
}
