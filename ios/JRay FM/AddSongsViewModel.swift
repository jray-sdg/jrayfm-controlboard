//
//  AddSongsViewModel.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation
import MusicKit
import Observation
import SwiftData

@Observable
final class AddSongsViewModel {
    private(set) var searchResults: [Song] = []
    private(set) var isSearching: Bool = false
    private(set) var errorMessage: String?
    
    @MainActor
    func search(term: String) async {
        guard !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            let request = MusicLibrarySearchRequest(term: term, types: [Song.self])
            let response = try await request.response()
            searchResults = Array(response.songs)
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    func clear() {
        searchResults = []
        errorMessage = nil
    }
}

enum LibrarySongFactory {
    static func makeLibrarySong(from song: Song) -> LibrarySong {
        LibrarySong(
            musicKitId: song.id.rawValue,
            title: song.title,
            artistName: song.artistName,
            albumTitle: song.albumTitle,
            artworkUrl: song.artwork?.url(width: 80, height: 80)
        )
    }
    
    static func isInLibrary(_ song: Song, existing: [LibrarySong]) -> Bool {
        existing.contains { $0.musicKitId == song.id.rawValue }
    }
}
