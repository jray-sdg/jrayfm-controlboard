//
//  Item.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation
import SwiftData

@Model
final class LibrarySong {
    @Attribute(.unique) var musicKitId: String
    
    var title: String
    var artistName: String
    var albumTitle: String?
    var artworkUrl: URL?
    var addedDate: Date
    
    var artworkUrlString: String?
    
    init(
        musicKitId: String,
        title: String,
        artistName: String,
        albumTitle: String? = nil,
        artworkUrl: URL? = nil,
        addedDate: Date = .now
    ) {
        self.musicKitId = musicKitId
        self.title = title
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.artworkUrl = artworkUrl
        self.addedDate = addedDate
    }
}
