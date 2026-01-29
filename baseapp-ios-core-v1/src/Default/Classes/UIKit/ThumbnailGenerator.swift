//
//  ThumbnailGenerator.swift
//  baseapp-ios-core-v1
//
//  Created by Pat Sluth on 2017-12-08.
//  Copyright © 2017 SilverLogic. All rights reserved.
//

#if os(iOS)

import AVKit
import Foundation
import Kingfisher
import PromiseKit

// MARK: - Static Variables
public extension ThumbnailGenerator {
    static let shared = ThumbnailGenerator()
}

// @available(iOS 10.0, *)
/// Generate `UIImage` thumbnail from `MediaURL`
public final class ThumbnailGenerator {
    let operationQueue: OperationQueue
    
    private init() {
        self.operationQueue = OperationQueue.make({
            $0.maxConcurrentOperationCount = 10
            $0.qualityOfService = .userInitiated
        })
    }
}

// MARK: - Public Instance Methods
public extension ThumbnailGenerator {
    func generate(for url: URL,
                  usingCache: Bool = true,
                  processor: ImageProcessor? = nil) -> Promise<KFCrossPlatformImage> {
        return Promise<MediaURL>
            .wrap({
                return try MediaURL(url: url)
            }).then({
                self.generate(
                    for: $0,
                    usingCache: usingCache,
                    processor: processor
                )
            })
    }
    
    /// Attempts to generate thumbnail 'targetSize'
    /// Supports image, video and pdf urls
    func generate(for mediaURL: MediaURL,
                  usingCache: Bool = true,
                  processor: ImageProcessor? = nil) -> Promise<KFCrossPlatformImage> {
        let cache = ImageCache.default
        let thumbnailCacheKey = "\(mediaURL.url.fileNameFull)_thumb_\(processor?.identifier ?? "unprocessed")"
        let (promise, resolver) = Promise<KFCrossPlatformImage>.pending()
        
        if !usingCache {
            cache.removeImage(forKey: thumbnailCacheKey)
        }
        
        let operation = BlockOperation()
        operation.addExecutionBlock({ [unowned operation] in
            guard !operation.isCancelled else { return }
            do {
                let image = try self.generateSync(for: mediaURL, processor: processor)
                
                cache.store(image,
                            forKey: thumbnailCacheKey,
                            options: KingfisherParsedOptionsInfo(nil),
                            toDisk: true)
                
                resolver.fulfill(image)
            } catch {
                resolver.reject(error)
            }
        })
        
        cache.retrieveImage(forKey: thumbnailCacheKey, options: nil, completionHandler: {
            guard promise.isPending else {
                resolver.reject(PMKError.cancelled)
                return
            }
            
            if let image = try? $0.get().image {
                resolver.fulfill(image)
            } else {
                self.operationQueue.addOperation(operation)
            }
        })
        
        return promise.recover({ [weak operation] error -> Promise<KFCrossPlatformImage> in
            if error.isCancelled {
                operation?.cancel()
            }
            throw error
        })
    }
    
    func generateSync(for mediaURL: MediaURL,
                      processor: ImageProcessor? = nil) throws -> KFCrossPlatformImage {
        return try mediaURL.generate()
        //        switch self {
        //        case let url where url.isImageURL:
        //            return try self.generateImageThumbnailSync(for: url,processor: processor)
        //        case let url where url.isVideoURL:
        //            return try self.generateVideoThumbnailSync(for: url,processor: processor)
        //        case let url where url.isPDFURL:
        //            return try self.generatePDFThumbnailSync(for: url,processor: processor)
        //        default:
        //            throw ThumbnailGeneratorError.InvalidURL(message: "Invalid URL")
        //        }
    }
}

public enum ThumbnailGeneratorError: Error {
    case InvalidURL
    case InvalidOptions
    case Failed
    case ProcessorFailed(unprocessed: KFCrossPlatformImage)
}

protocol ThumbnailGeneratorOptionsProtocol {
    static var defaultOptions: Self { get }
}

public protocol AnyThumbnailGenerator {
    var url: URL { get }
    init(url: URL) throws
}

extension AnyThumbnailGenerator
where Self: ThumbnailGeneratorProtocol {
}

protocol ThumbnailGeneratorProtocol: AnyThumbnailGenerator {
    associatedtype OptionsType: ThumbnailGeneratorOptionsProtocol
    
    var url: URL { get }
    init(url: URL) throws
    
    /// Generate thumbnail image sync
    func generate(with options: OptionsType) throws -> KFCrossPlatformImage
}

// class AnyThumbnailGenerator<>

struct ImageThumbnailGenerator: ThumbnailGeneratorProtocol {
    typealias OptionsType = Options
    
    struct Options: ThumbnailGeneratorOptionsProtocol {
        
        
        static var defaultOptions: Options {
            return Options()
        }
    }
    
    
    
    let url: URL
    
    init(url: URL) throws {
        guard url.isImageURL else { throw ThumbnailGeneratorError.InvalidURL }
        
        self.url = url
    }
    
    func generate(with options: Options = Options.defaultOptions) throws -> KFCrossPlatformImage {
        guard let data = try? Data(contentsOf: self.url), let image = UIImage(data: data) else {
            throw ThumbnailGeneratorError.Failed
        }
        
        return image
    }
}

struct VideoThumbnailGenerator: ThumbnailGeneratorProtocol {
    typealias OptionsType = Options
    
    struct Options: ThumbnailGeneratorOptionsProtocol {
        let seconds: Double
        
        static var defaultOptions: Options {
            return Options(seconds: 1.0)
        }
    }
    
    
    
    let url: URL
    
    init(url: URL) throws {
        guard url.isVideoURL else { throw ThumbnailGeneratorError.InvalidURL }
        
        self.url = url
    }
    
    func generate(with options: Options = Options.defaultOptions) throws -> KFCrossPlatformImage {
        let asset = AVURLAsset(url: self.url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let track = asset.tracks(withMediaType: .video).first {
            generator.maximumSize = track.naturalSize * UIScreen.main.scale
        }
        
        let timescale: Int32 = 1000
        let atTime = CMTime(seconds: options.seconds, preferredTimescale: timescale)
        var actualTime = CMTime(seconds: options.seconds, preferredTimescale: timescale)
        
        let cgImage = try generator.copyCGImage(at: atTime, actualTime: &actualTime)
        let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        
        return image
    }
}

struct PDFThumbnailGenerator: ThumbnailGeneratorProtocol {
    typealias OptionsType = Options
    
    struct Options: ThumbnailGeneratorOptionsProtocol {
        let page: UInt
        let backgroundColor: UIColor
        
        static var defaultOptions: Options {
            return Options(page: 1, backgroundColor: UIColor.white)
        }
    }
    
    
    
    let url: URL
    let document: CGPDFDocument
    
    init(url: URL) throws {
        guard url.isPDFURL, let document = CGPDFDocument(url as CFURL) else {
            throw ThumbnailGeneratorError.InvalidURL
        }
        
        self.url = url
        self.document = document
    }
    
    func generate(with options: Options = Options.defaultOptions) throws -> KFCrossPlatformImage {
        guard let page = self.document.page(at: Int(options.page)) else {
            throw ThumbnailGeneratorError.InvalidOptions
        }
        
        let rect = page.getBoxRect(.mediaBox)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            throw ThumbnailGeneratorError.Failed
        }
        
        context.saveGState()
        context.setFillColor(options.backgroundColor.cgColor)
        context.fill(rect)
        context.translateBy(x: 0.0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.concatenate(
            page.getDrawingTransform(
                CGPDFBox.mediaBox,
                rect: rect,
                rotate: 0,
                preserveAspectRatio: true
            )
        )
        context.drawPDFPage(page)
        context.restoreGState()
        
        UIGraphicsEndImageContext()
        
        guard let cgImage = context.makeImage() else {
            throw ThumbnailGeneratorError.Failed
        }
        
        let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        
        return image
    }
}

extension MediaURL {
    func generate() throws -> KFCrossPlatformImage {
        switch self {
        case .image(let url):
            return try ImageThumbnailGenerator(url: url).generate()
        case .video(let url):
            return try VideoThumbnailGenerator(url: url).generate()
        case .pdf(let url):
            return try PDFThumbnailGenerator(url: url).generate()
        }
    }
}

#endif
