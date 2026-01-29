//
//  MediaPicker.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2018-01-24.
//  Copyright © 2018 SilverLogic. All rights reserved.
//

#if os(iOS)

import Alertift
import CoreServices
import DeviceKit
import Foundation
import PromiseKit
import UIKit
import UniformTypeIdentifiers

/// A class for picking images/video from the device
@available(iOS 11.0, *)
public final class MediaPicker: NSObject {
    public struct MediaItem {
        public let type: MediaPicker.MediaType
        public let fileURL: URL
    }
    
    public enum MediaType: String, CaseIterable {
        case image
        case video
        
        /// CoreServices type for UIImagePickerController
        fileprivate var kUTType: String {
            if #available(iOS 15.0, *) {
                switch self {
                case .image:    
                    return UTType.image.identifier
                case .video:    
                    return UTType.movie.identifier
                }
            } else {
                switch self {
                case .image:    
                    return kUTTypeImage as String
                case .video:    
                    return kUTTypeMovie as String
                }
            }
        }
    }
    
    private let (promise, resolver) = Promise<MediaItem>.pending()
    
    private var viewController: UIViewController? {
        didSet {
            viewController?.set(associatedObject: "\(type(of: self))", object: self)
            
            if viewController == nil {
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private(set) lazy var imagePickerController = UIImagePickerController.make({
        $0.delegate = self
        $0.allowsEditing = true
    })
    
    private override init() {
        fatalError("\(#function) not supported")
    }
    
    deinit {
        if promise.isPending {
            resolver.reject(PMKError.cancelled)
        }
    }
    
    private init(
        viewController: UIViewController,
        anchorView: UIView? = nil,
        tintColor: UIColor? = nil,
        _ mediaTypes: Set<MediaType>
    ) {
        super.init()
        
        defer {
            self.viewController = viewController
        }
        
        let executeAction = { (sourceType: UIImagePickerController.SourceType) in
            self.imagePickerController.sourceType = sourceType
            self.imagePickerController.mediaTypes = mediaTypes.map({ $0.kUTType })
            self.imagePickerController.present(from: viewController)
        }
        
        guard !Device.current.isSimulator else {
            executeAction(.photoLibrary)
            return
        }
        
        let alert = (anchorView == nil) ?
            Alertift.actionSheet(title: nil, message: nil) :
            Alertift.actionSheet(title: nil, message: nil, anchorView: anchorView!)
        alert
            .action(.cancel("Cancel"), handler: { _, _ in
                self.didSelect(output: nil)
            })
            .action(.default("Choose from library"), handler: { _, _ in
                executeAction(.photoLibrary)
            })
            .action(.default("Take"), handler: { _, _ in
                executeAction(.camera)
            })
            .buttonTextColor(tintColor)
            .show(on: viewController, completion: nil)
    }
}


// MARK: - Class Methods
@available(iOS 11.0, *)
public extension MediaPicker {
    @discardableResult
    class func pick(
        from viewController: UIViewController,
        anchorView: UIView? = nil,
        tintColor: UIColor? = nil,
        _ mediaTypes: Set<MediaType>
    ) -> Promise<MediaItem> {
        return MediaPicker(
            viewController: viewController,
            anchorView: anchorView,
            tintColor: tintColor,
            mediaTypes
        ).promise
    }
}


// MARK: - Private Instance Methods
@available(iOS 11.0, *)
private extension MediaPicker {
    private func didSelect(output: MediaItem?) {
        if let output = output {
            resolver.fulfill(output)
        } else {
            resolver.reject(PMKError.cancelled)
        }
        viewController = nil
    }
}

@available(iOS 11.0, *)
extension MediaPicker: UINavigationControllerDelegate & UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        var output: MediaItem?
        
        if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
            if let data = image.pngData() {
                let fileURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(image.hash).png")
                do {
                    try data.write(to: fileURL)
                    output = MediaItem(type: .image, fileURL: fileURL)
                } catch {
                    logger.error(error)
                }
            }
        } else if let fileURL = info[.imageURL] as? URL {
            output = MediaItem(type: .image, fileURL: fileURL)
        } else if let fileURL = info[.mediaURL] as? URL {
            output = MediaItem(type: .video, fileURL: fileURL)
        }
        
        didSelect(output: output)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didSelect(output: nil)
    }
}

#endif
