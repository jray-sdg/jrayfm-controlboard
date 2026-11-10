//
//  AddSongsViewModel.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation
import MusicKit

enum LibrarySongFactory {
    static func makeLibrarySong(from song: Song) -> LibrarySong {
        LibrarySong(
            musicKitId: song.id.rawValue,
            title: song.title,
            artistName: song.artistName,
            albumTitle: song.albumTitle,
            artworkUrl: song.artwork?.url(width: 80, height: 80),
            artworkData: encodedArtwork(for: song)
        )
    }

    static func encodedArtwork(for song: Song) -> Data? {
        guard let artwork = song.artwork else { return nil }
        return try? JSONEncoder().encode(artwork)
    }
}
