//
//  PlaylistStore.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation

enum PlaylistStore {
    private static let songIDsKey = "currentPlaylist.songIDs"
    private static let currentIndexKey = "currentPlaylist.currentIndex"

    static func save(songIDs: [String], currentIndex: Int) {
        UserDefaults.standard.set(songIDs, forKey: songIDsKey)
        UserDefaults.standard.set(currentIndex, forKey: currentIndexKey)
    }

    static func saveIndex(_ index: Int) {
        UserDefaults.standard.set(index, forKey: currentIndexKey)
    }

    static func loadSongIDs() -> [String]? {
        UserDefaults.standard.stringArray(forKey: songIDsKey)
    }

    static func loadCurrentIndex() -> Int {
        UserDefaults.standard.integer(forKey: currentIndexKey)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: songIDsKey)
        UserDefaults.standard.removeObject(forKey: currentIndexKey)
    }
}
