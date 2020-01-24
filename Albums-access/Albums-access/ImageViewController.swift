//
//  ImageViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/23/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVKit

class ImageViewController:UIViewController{

    var asset: Asset?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButon: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let asset = asset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImage(
                for: asset.phAsset,
                targetSize: CGSize(width: 1500, height: 1500),
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
                print("other")
            case .audio:
                print("other")
             default:
                print("other")
            }
            
        }
    }
    
    func playVideo (view: UIViewController, videoAsset:PHAsset){
     PHCachingImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (asset, _, _) in
            let asset = asset as! AVURLAsset

            DispatchQueue.main.async {
                let player = AVPlayer(url: asset.url)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                view.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
        
    @IBAction func pressPlayButon(_ sender: Any) {
        //playButon.isHidden = true
        playVideo(view: self, videoAsset: asset!.phAsset)
    }
    
}
