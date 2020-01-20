//
//  PHAssetExtension.swift
//  Demo-download
//
//  Created by Solaborate on 1/10/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {

    enum GetURLError: Error {
        case unhandledMediaType
        case unknownError
    }

    func getURL(
        _ completion: @escaping (Swift.Result<URL, Error>) -> Void
    ) {
        switch mediaType {
        case .image:
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ in return true }

            requestContentEditingInput(with: options) { (contentEditingInput, _) -> Void in
                if let url = contentEditingInput?.fullSizeImageURL {
                    completion(.success(url))
                } else {
                    completion(.failure(GetURLError.unknownError))
                }
            }

        case.video:
            let options = PHVideoRequestOptions()
            options.version = .original

            PHImageManager.default().requestAVAsset(
                forVideo: self,
                options: options
            ) { (asset, audioMix, info) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    completion(.success(urlAsset.url))
                } else {
                    completion(.failure(GetURLError.unknownError))
                }
            }
        default:
            completion(.failure(GetURLError.unhandledMediaType))
        }
    }
}
