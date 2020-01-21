//
//  PHAssetExtension.swift
//  Demo-download
//
//  Created by Solaborate on 1/10/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//
import UIKit
import Foundation
import Photos

extension PHAsset {

    enum GetURLError: Error {
        case unhandledMediaType
        case unknownError
    }

    func getUIImg(
        _ completion: @escaping (Swift.Result<UIImage, Error>) -> Void
    ) {
        switch mediaType {
        case .image:
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ in return true }

            requestContentEditingInput(with: options) { (contentEditingInput, _) -> Void in
                if let img = contentEditingInput?.displaySizeImage?.af_imageAspectScaled(toFill: CGSize(width: 150, height: 150)) {
                    completion(.success(img))
                } else {
                    completion(.failure(GetURLError.unknownError))
                }
            }

        case.video:
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            manager.requestImage(for: self, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let thumbnail = result{
                    completion(.success(thumbnail))
                }else{
                    completion(.failure(GetURLError.unknownError))
                }
                })
            //             { (asset, audioMix, info) -> Void in
            //                if let video = asset as? AVURLAsset {
            //                    completion(.success(video.))
            //                } else {
            //                    completion(.failure(GetURLError.unknownError))
            //                }
        //            }
        default:
            completion(.failure(GetURLError.unhandledMediaType))
        }
    }
}
