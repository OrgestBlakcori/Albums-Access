//
//  AlbumsCollectionViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/20/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//

import UIKit
import Photos

class AlbumsCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var albumIdentifier: String!
    private var images: [UIImage?] = []
    
    private let reuseIdentifier = "PhotoCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAlbum()
    }

    func loadAlbum() {
        guard let albumIdentifier = albumIdentifier else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
                        
            guard let album = PHAssetCollection.fetchAssetCollections(
                    withLocalIdentifiers: [albumIdentifier],
                    options: PHFetchOptions()
                ).firstObject else {
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var images: [UIImage?] = []
            
            let albumAssets = PHAsset.fetchAssets(in: album, options: nil)
            
            
            albumAssets.enumerateObjects { (asset, _, _) in
                dispatchGroup.enter()
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: 200, height: 200),
                    contentMode: .aspectFill,
                    options: options
                ) { (image, _) in
                    images.append(image)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak strongSelf] in
                guard let strongSelf = strongSelf else {
                    return
                }
                
                strongSelf.images = images
                strongSelf.collectionView.reloadData()
            }
        }
    }

    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let image = images[indexPath.row]
        
        if let photoCell = cell as? PhotoCell {
            if let image = image {
                photoCell.imageLabel.image = image
            } else {
                photoCell.imageLabel.image = UIImage(named: "DefaultImg")
            }
        }
        
        return cell
    }
    
}
