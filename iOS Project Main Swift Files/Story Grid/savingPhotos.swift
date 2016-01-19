//
//  savingPhotos.swift
//  StoryGrid
//
//  Created by Andrew Whitman on 2015-10-02.
//  Copyright © 2015 awhitman92. All rights reserved.
//

import Foundation
import Photos
import PKHUD

class CustomPhotoAlbum {
    
    static let albumName = "Story Grid"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            if let firstObject: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(CustomPhotoAlbum.albumName)
            }) { success, _ in
                if success {
                    self.assetCollection = fetchAssetCollectionForAlbum()
                }
        }
    }
    
    func saveImage(image: UIImage) -> Bool{
        if assetCollection == nil {
            print("assetcollection = nil")
            return false
        }
        var result: Bool = true
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset!
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)!
            albumChangeRequest.addAssets([assetPlaceholder])
            }, completionHandler: { (success, error) -> Void in
                NSLog("Finished deleting asset. %@", (success ? "Success" : error!))
                if(success != true){
                    result = false
                }
        })
        return result
    }
    
}