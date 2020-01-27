//  ImageViewController.swift
//  Albums-access
//  Created by Solaborate on 1/23/20.
//  Copyright © 2020 Solaborate. All rights reserved.
import Foundation
import UIKit
import Photos
import AVKit

class ImageViewController:UIViewController, UIScrollViewDelegate{

    var asset: Asset?
    static let shared = ImageViewController()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButon: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        getVideo()
        
    }

    func getVideo(){
        scrollView.contentInsetAdjustmentBehavior = .never
        if let asset = asset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImage(
                for: asset.phAsset,
                targetSize: CGSize(width: 1000, height: 1000),
                contentMode: .aspectFit,
                options: options
            ) { [weak self] (image, _) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.imageView.image = image
            }
            switch asset.phAsset.mediaType {
            case .video:
                playButon.isHidden = false
                print("Video")
            case .unknown:
                print("other")
            case .image:
                scrollView.maximumZoomScale = 4
                scrollView.minimumZoomScale = 1
                let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
                doubleTapGest.numberOfTapsRequired = 2
                scrollView.addGestureRecognizer(doubleTapGest)
                print("other")
            case .audio:
                print("other")
             default:
                print("other")
            }
        }

    }

    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        }
        else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height

                let ratio = ratioW < ratioH ? ratioW : ratioH
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let conditionLeft = newWidth*scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                let conditioTop = newHeight*scrollView.zoomScale > imageView.frame.height

                let top = 0.5 * (conditioTop ? newHeight - imageView.frame.height : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)

            }
        } else {
            scrollView.contentInset = .zero
        }
    }

//    func playVideo (view: UIViewController, videoAsset:PHAsset){
//     PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, _, _) in
//            let asset = asset as! AVURLAsset
//            DispatchQueue.main.async {
//                print(asset.accessibilityFrame)
//                let player = AVPlayer(url: asset.url)
//                let playerViewController = AVPlayerViewController()
//                playerViewController.player = player
//                view.present(playerViewController, animated: true) {
//                    playerViewController.player!.play()
//                }
//            }
//        }
//    }

    @IBAction func pressPlayButon(_ sender: Any) {
//        playVideo(view: self, videoAsset: asset!.phAsset)
        PHCachingImageManager().requestAVAsset(forVideo: asset!.phAsset, options: nil) { (asset, _, _) in
            let asset = asset as! AVURLAsset
            let videoLauncher = VideoLauncher()
            DispatchQueue.main.async {
            videoLauncher.showVideoPlayer(assetUrl: asset.url)
            }
        }
    }
}
