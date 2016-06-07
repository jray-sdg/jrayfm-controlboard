//
//  LibraryEntry.swift
//  JRay FM
//
//  Created by Jonathan Ray on 4/19/16.
//  Copyright © 2016 Jonathan Ray. All rights reserved.
//

import MediaPlayer
import UIKit

class LibraryEntry {
    
    private(set) var name: String
    private(set) var artist: String
    private(set) var image: UIImage
    private(set) var id: UInt64
    
    init() {
        self.name = "[Empty Item]"
        self.artist = "[Empty Item]"
        self.image = UIImage(named: "unknownAlbumArt")!
        self.id = UInt64.max
    }
    
    init(entryName: String, entryArtist: String, entryImage: UIImage, entryId: UInt64) {
        self.name = entryName
        self.artist = entryArtist
        self.image = entryImage
        self.id = entryId
    }
    
    convenience init(mediaItem: MPMediaItem) {
        let id = mediaItem.persistentID
        let name = mediaItem.title
        let artist = mediaItem.artist
        let image = mediaItem.artwork
        var uiImage = image?.imageWithSize(image!.bounds.size)
        
        if uiImage == nil {
            uiImage = UIImage(named: "unknownAlbumArt")
        }
        
        self.init(entryName: name!, entryArtist: artist!, entryImage: uiImage!, entryId: id)
    }
    
    func isEmpty() -> Bool {
        return self.id == UInt64.max
    }
}
