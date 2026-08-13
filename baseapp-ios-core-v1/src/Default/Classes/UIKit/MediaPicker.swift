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
import Photos
import PhotosUI
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
                presentedPicker?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// The picker currently on screen — either the camera (`UIImagePickerController`) or the
    /// photo library (`PHPickerViewController`). Tracked so it can be dismissed on completion.
    private weak var presentedPicker: UIViewController?
    
    /// Used only for camera capture; `PHPickerViewController` handles the photo library.
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
        
        guard !Device.current.isSimulator else {
            // The simulator has no camera, so go straight to the library picker.
            self.presentPhotoLibrary(from: viewController, mediaTypes)
            return
        }
        
        let alert = (anchorView == nil) ?
        Alertift.actionSheet(title: nil, message: nil) :
        Alertift.actionSheet(title: nil, message: nil, anchorView: anchorView!)
        alert.action(.cancel("Cancel"), handler: { _, _ in
            self.didSelect(output: nil)
        })
        // PHPickerViewController is always available and runs out-of-process, so it needs
        // no photo library permission (or source-type availability check).
        alert.action(.default("Choose from library"), handler: { _, _ in
            self.presentPhotoLibrary(from: viewController, mediaTypes)
        })
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.action(.default("Take"), handler: { _, _ in
                self.presentCamera(from: viewController, mediaTypes)
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
    /// Presents the system camera via `UIImagePickerController` — `PHPickerViewController`
    /// has no camera capture, so the camera path still uses the legacy picker.
    private func presentCamera(from viewController: UIViewController, _ mediaTypes: Set<MediaType>) {
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = mediaTypes.map({ $0.kUTType })
        presentedPicker = imagePickerController
        imagePickerController.present(from: viewController)
    }
    
    /// Presents the photo library via `PHPickerViewController`.
    private func presentPhotoLibrary(from viewController: UIViewController, _ mediaTypes: Set<MediaType>) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        let filters = mediaTypes.map({ mediaType -> PHPickerFilter in
            switch mediaType {
            case .image:
                return .images
            case .video:
                return .videos
            }
        })
        if !filters.isEmpty {
            configuration.filter = .any(of: filters)
        }
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        presentedPicker = picker
        viewController.present(picker, animated: true, completion: nil)
    }
    
    /// Copies the picked item out of its (temporary) location and resolves the promise.
    private func loadMediaItem(from itemProvider: NSItemProvider) {
        let type: MediaType
        let typeIdentifier: String
        if itemProvider.hasItemConformingToTypeIdentifier(MediaType.video.kUTType) {
            type = .video
            typeIdentifier = MediaType.video.kUTType
        } else if itemProvider.hasItemConformingToTypeIdentifier(MediaType.image.kUTType) {
            type = .image
            typeIdentifier = MediaType.image.kUTType
        } else {
            didSelect(output: nil)
            return
        }
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
            guard let self = self else { return }
            
            var output: MediaItem?
            if let url = url {
                // `loadFileRepresentation` deletes the supplied URL once this closure returns,
                // so copy it into our own temporary location to hand back to the caller.
                let destination = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                do {
                    try FileManager.default.copyItem(at: url, to: destination)
                    output = MediaItem(type: type, fileURL: destination)
                } catch {
                    logger.error(error)
                }
            } else if let error = error {
                logger.error(error)
            }
            
            DispatchQueue.main.async {
                self.didSelect(output: output)
            }
        }
    }
    
    /// Saves a captured media item to the device's camera roll.
    ///
    /// Uses `PHAssetChangeRequest` with the original file URL so the asset's metadata
    /// (EXIF/GPS/orientation) is preserved rather than re-encoded.
    /// Requires `NSPhotoLibraryAddUsageDescription` in the host app's Info.plist.
    private func persistToCameraRoll(_ item: MediaItem) {
        PHPhotoLibrary.shared().performChanges {
            switch item.type {
            case .image:
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: item.fileURL)
            case .video:
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: item.fileURL)
            }
        } completionHandler: { success, error in
            if !success {
                logger.log(.error, "Failed to save \(item.type) to camera roll: \(String(describing: error))")
            }
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
            if let data = image.jpegData(compressionQuality: 0.9) {
                let fileURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(image.hash).jpg")
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

@available(iOS 14.0, *)
extension MediaPicker: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss immediately; loading the item below is asynchronous.
        picker.dismiss(animated: true, completion: nil)
        
        if let itemProvider = results.first?.itemProvider {
            loadMediaItem(from: itemProvider)
        } else {
            didSelect(output: nil)
        }
    }
}

#endif
