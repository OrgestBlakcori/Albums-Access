//
//  AlbumsCollectionViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/20/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//

import UIKit
import Photos

struct Asset {
    let phAsset: PHAsset
    let image: UIImage?
}

class AlbumsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var album: Album?
    private var assets: [Asset] = []
    var selectedIndexPath: IndexPath!
    private let reuseIdentifier = "PhotoCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlbum()
    }

    func loadAlbum() {
        guard let album = album else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
                        
            let dispatchGroup = DispatchGroup()
            var assets: [Asset] = []
            
            for phAsset in album.phAssets {
                dispatchGroup.enter()
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(
                    for: phAsset,
                    targetSize: CGSize(width: 200, height: 200),
                    contentMode: .aspectFill,
                    options: options
                ) { (image, _) in
                    assets.append(Asset(
                        phAsset: phAsset,
                        image: image
                    ))
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak strongSelf] in
                guard let strongSelf = strongSelf else {
                    return
                }
                
                strongSelf.assets = assets
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width/3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        selectedIndexPath = indexPath
        if let photoViewController = storyboard.instantiateViewController(identifier: "ImageViewController") as? ImageViewController {
            photoViewController.asset = assets[indexPath.row]
            navigationController?.pushViewController(photoViewController, animated: true)
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let image = assets[indexPath.row].image
        let video = assets[indexPath.row].phAsset
        if let photoCell = cell as? PhotoCell {
            if let image = image {
                photoCell.imageLabel.image = image
                
                if video.mediaType == .video {
                    photoCell.isVideo.isHidden = false
                    photoCell.isVideo.text = "\(Int(video.duration)/60):\(Int(video.duration)%60)"
                }
            } else {
                photoCell.imageLabel.image = UIImage(named: "DefaultImg")
            }
            

            
        }
//        if (phAsset.mediaType == .video){
//
//        }
        return cell
    }
    
}

extension AlbumsCollectionViewController: ZoomingViewController {
    
    func zooomingBackgroundView(for transition: ZoomTransitioningDelegate) -> UIView? {
        return nil
    }
    
    func zoomingImageView(for transition: ZoomTransitioningDelegate) -> UIImageView? {
        if let indexPath = selectedIndexPath {
            let cell = collectionView?.cellForItem(at: indexPath) as? PhotoCell
            return cell?.imageLabel
        }
        return nil
    }
    
    }
