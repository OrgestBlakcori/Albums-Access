//  ViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/17/20.
//  Copyright © 2020 Solaborate. All rights reserved.
import UIKit
import Foundation
import Photos
import AlamofireImage
import JGProgressHUD

struct Album {
    let localIdentifier: String
    let localizedTitle: String?
    var thumbnail: UIImage?
}

class ViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var albumModels: [Album] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.requestAuthorization { [weak self] (authorizationStatus) in
            guard let strongSelf = self,
                authorizationStatus == .authorized else {
                return
            }
            
            strongSelf.loadData()
        }
    }

    func loadData() {
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let hud = JGProgressHUD(style: .dark)
            DispatchQueue.main.async {
                
                hud.textLabel.text = "Loading"
                hud.show(in: strongSelf
                    .view)
            }

            let dispatchGroup = DispatchGroup()

            var albumModels: [Album] = []
            
            let albumsSmart = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .any,
                options: nil
            )
            
            let albums = PHAssetCollection.fetchAssetCollections(
                with: .album,
                subtype: .any,
                options: nil
            )
            
            albums.enumerateObjects { (phAssetCollection, _, _) in
                if !albumModels.contains(where: {$0.localIdentifier == phAssetCollection.localIdentifier}){
                    dispatchGroup.enter()
                    
                    albumModels.append(Album(
                        localIdentifier: phAssetCollection.localIdentifier,
                        localizedTitle: phAssetCollection.localizedTitle,
                        thumbnail: nil
                        ))
                    
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.fetchLimit = 1
                    
                    if let lastAsset = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions).firstObject{
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .highQualityFormat
                        
                        PHImageManager.default().requestImage(
                            for: lastAsset,
                            targetSize: CGSize(width: 150, height: 150),
                            contentMode: .aspectFill,
                            options: options
                        ) { (image, _) in
                            if let index = albumModels.firstIndex(where: {$0.localIdentifier == phAssetCollection.localIdentifier}){
                                albumModels[index].thumbnail = image
                            }
                            dispatchGroup.leave()
                        }
                    }else{dispatchGroup.leave()
                    }
                }
            }
            
            albumsSmart.enumerateObjects { (phAssetCollection, _, _) in
                if !albumModels.contains(where: { $0.localIdentifier == phAssetCollection.localIdentifier }) {
                    dispatchGroup.enter()

                    albumModels.append(Album(
                        localIdentifier: phAssetCollection.localIdentifier,
                        localizedTitle: phAssetCollection.localizedTitle,
                        thumbnail: nil
                    ))
                    
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    fetchOptions.fetchLimit = 1
                    
                    if let lastAsset = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions).firstObject {
                        let options = PHImageRequestOptions()
                        options.deliveryMode = .highQualityFormat
                        
                        PHImageManager.default().requestImage(
                            for: lastAsset,
                            targetSize: CGSize(width: 150, height: 150),
                            contentMode: .aspectFill,
                            options: options
                        ) { (image, _) in
                            if let index = albumModels.firstIndex(where: { $0.localIdentifier == phAssetCollection.localIdentifier }) {
                                albumModels[index].thumbnail = image
                            }
                            
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }
            
            
            
            dispatchGroup.notify(queue: .main) { [weak strongSelf] in
                guard let strongSelf = strongSelf else {
                    return
                }
                hud.dismiss()
                strongSelf.albumModels = albumModels
                strongSelf.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumModels.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCellId", for: indexPath)
        let album = albumModels[indexPath.row]
        
        if let albumCell = cell as? AlbumCell{
            albumCell.albumsTitle.text = album.localizedTitle
            if (album.thumbnail == nil){
                albumCell.albumsFirstImage.image = UIImage(named: "DefaultImg")
                
            }
            else{
            albumCell.albumsFirstImage.image = album.thumbnail
            }
            albumCell.albumsFirstImage.layer.cornerRadius = 8.0
        }
        
        return cell
    }
}
