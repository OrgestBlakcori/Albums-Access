//  ViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/17/20.
//  Copyright © 2020 Solaborate. All rights reserved.
import UIKit
import Foundation
import Photos
import AlamofireImage

class ViewController: UIViewController,
    UITableViewDelegate,
UITableViewDataSource {
    
    
    var imageArray = [UIImage]()
    var albumsTitles:[String]=[]
    var urls: [URL] = []
    var photo:UIImage?
    var images:[UIImage]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        fetchCustomAlbumPhotos()
        print(images.count)
    }
    
    func loadData(){
        var assets:[PHAsset]=[]
        let dispatchGroup = DispatchGroup()
        let albumList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options:nil)
        for i in 0..<albumList.count{
             let album = albumList.object(at: i)
             self.albumsTitles.append(album.localizedTitle!)
            print(album.localizedTitle)
        }
        
        for asset in assets{
            dispatchGroup.enter()
            asset.getURL { [weak self] (result) in
                guard let strongSelf = self else {
                    return
                }

                switch result {
                case .failure(let error):
                    print("Could not get url for asset with identifier: \(asset.localIdentifier). Error: \(error.localizedDescription)")

                case .success(let url):
                    strongSelf.urls.append(url)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            print(strongSelf.urls)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsTitles.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCellId", for: indexPath)
        let album = albumsTitles[indexPath.row]
        if let albumCell = cell as? AlbumCell{
            albumCell.albumsTitle.text = album
        }
        return cell
    }
    
    func fetchCustomAlbumPhotos()
    {
        let albumName = "Recents"
        var assetCollection = PHAssetCollection()
        var albumFound = Bool()
        var photoAssets = PHFetchResult<AnyObject>()
        let fetchOptions = PHFetchOptions()

        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)

        if let firstObject = collection.firstObject{
            //found the album
            assetCollection = firstObject
            albumFound = true
        }
        else { albumFound = false
        }
        _ = collection.count
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil) as! PHFetchResult<AnyObject>
        let imageManager = PHCachingImageManager()
        photoAssets.enumerateObjects{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in

            if object is PHAsset{
                let asset = object as! PHAsset
                print("Inside  If object is PHAsset, This is number 1")

                let imageSize = CGSize(width: asset.pixelWidth,
                                       height: asset.pixelHeight)

                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .fastFormat
                options.isSynchronous = true

                imageManager.requestImage(for: asset,
                                                  targetSize: imageSize,
                                                  contentMode: .aspectFill,
                                                  options: options,
                                                  resultHandler: {
                                                    (image, info) -> Void in
                                                    self.photo = image!
                                                    /* The image is now available to us */
                                                    self.addImgToArray(uploadImage: self.photo!)
                                                    print("enum for image, This is number 2")

                })

            }
        }
    }

    func addImgToArray(uploadImage:UIImage)
    {
        self.images.append(uploadImage)

    }
    

//    func getPhotosFromAlbum() {
//
//        let imageManager = PHImageManager.default()
//
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//        requestOptions.deliveryMode = .highQualityFormat
//
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//            if fetchResult.count > 0 {
//
//                for i in 0..<fetchResult.count {
//
//                    imageManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOptions, resultHandler: { image, error in
//
//                        self.imageArray.append(image!)
//                    })
//                }
//            } else {
//                print("nada")
//        }
//    }
}
