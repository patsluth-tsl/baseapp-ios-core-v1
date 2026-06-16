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
    
    /// When `true`, media captured with the camera is also saved to the device's camera roll.
    private var saveToCameraRoll: Bool = false
    
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
        saveToCameraRoll: Bool = false,
        _ mediaTypes: Set<MediaType>
    ) {
        super.init()
        
        self.saveToCameraRoll = saveToCameraRoll
        
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
        alert.action(.cancel("Cancel"), handler: { _, _ in
            self.didSelect(output: nil)
        })
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.action(.default("Choose from library"), handler: { _, _ in
                executeAction(.photoLibrary)
            })
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.action(.default("Take"), handler: { _, _ in
                executeAction(.camera)
            })
        }
        alert
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
        saveToCameraRoll: Bool = false,
        _ mediaTypes: Set<MediaType>
    ) -> Promise<MediaItem> {
        return MediaPicker(
            viewController: viewController,
            anchorView: anchorView,
            tintColor: tintColor,
            saveToCameraRoll: saveToCameraRoll,
            mediaTypes
        ).promise
    }
}


// MARK: - Private Instance Methods
@available(iOS 11.0, *)
private extension MediaPicker {
    /// Saves a captured media item to the device's camera roll.
    ///
    /// Requires `NSPhotoLibraryAddUsageDescription` in the host app's Info.plist.
    private func persistToCameraRoll(_ item: MediaItem) {
        switch item.type {
        case .image:
            guard let image = UIImage(contentsOfFile: item.fileURL.path) else {
                logger.error("Failed to load captured image for camera roll: \(item.fileURL)")
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        case .video:
            let path = item.fileURL.path
            guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) else {
                logger.error("Captured video is not compatible with the camera roll: \(path)")
                return
            }
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
        }
    }
    
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
        
        if let image = (info[.originalImage]) as? UIImage {
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
        
        // Only persist to the camera roll for media that was just captured with the
        // camera — items chosen from the library are already there.
        if saveToCameraRoll, picker.sourceType == .camera, let output = output {
            persistToCameraRoll(output)
        }
        
        didSelect(output: output)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didSelect(output: nil)
    }
}

#endif
