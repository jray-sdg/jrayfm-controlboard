//
//  PlaybackController.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation
import MusicKit
import Observation
internal import Combine

@Observable
@MainActor
final class PlaybackController {
    
    init(_ player: ApplicationMusicPlayer) {
        self.player = player
        
        subscribeToState()
        subscribeToQueue()
    }
    
    private let player: ApplicationMusicPlayer
    
    private var stateCancellable: AnyCancellable?
    private var queueCancellable: AnyCancellable?

    private(set) var currentSong: Song?
    private(set) var isPlaying : Bool = false
    private(set) var errorMessage: String?

    private(set) var hasQueue = false
    private(set) var currentIndex : Int?
    private(set) var queueLength : Int?
    
    var canSkipForward: Bool {
        guard let currentIndex, let queueLength else { return false }
        return currentIndex < queueLength - 1
    }
    
    private func subscribeToState() {
        stateCancellable = player.state.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateFromState()
                }
            }
        updateFromState()
    }
    
    private func subscribeToQueue() {
        queueCancellable = player.queue.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateFromQueue()
                }
            }
        updateFromQueue()
    }
    
    private func setQueue(_ queue: ApplicationMusicPlayer.Queue) {
        player.queue = queue
        subscribeToQueue()
    }

    func load(songs: [Song]) async {
        guard !songs.isEmpty else { return }

        errorMessage = nil
        queueLength = songs.count
        setQueue(ApplicationMusicPlayer.Queue(for: songs))

        do {
            try await player.play()
            PlaylistStore.save(songIDs: songs.map(\.id.rawValue), currentIndex: 0)
        } catch {
            errorMessage = "Playback failed: \(error.localizedDescription)"
        }
    }
    
    func loadWithoutPlaying(songs: [Song], startingAt index: Int) async {
        guard !songs.isEmpty else { return }
        let safeIndex = min(max(index, 0), songs.count - 1)
        
        errorMessage = nil
        queueLength = songs.count
        setQueue(ApplicationMusicPlayer.Queue(for: songs, startingAt: songs[safeIndex]))
        
        do {
            try await player.prepareToPlay()
        } catch {
            errorMessage = "Couldn't prepare playback: \(error.localizedDescription)"
        }
    }

    func togglePlayPause() {
        if player.state.playbackStatus == .playing {
            player.pause()
        } else {
            Task {
                do {
                    try await player.play()
                } catch {
                    errorMessage = "Playback failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func skipToNext() {
        Task {
            do {
                try await player.skipToNextEntry()
            } catch {
                errorMessage = "Skip failed: \(error.localizedDescription)"
            }
        }
    }

    func skipToPrevious() {
        Task {
            do {
                try await player.skipToPreviousEntry()
            } catch {
                errorMessage = "Skip failed: \(error.localizedDescription)"
            }
        }
    }
    
    func setError(_ message: String) {
        errorMessage = message
    }
    
    private func updateFromState() {
        isPlaying = player.state.playbackStatus == .playing
    }
    
    private func updateFromQueue() {
        if let entry = player.queue.currentEntry,
           case .song(let song) = entry.item {
            currentSong = song
            if let index = player.queue.entries.firstIndex(where: { $0.id == entry.id }) {
                currentIndex = index
                PlaylistStore.saveIndex(index)
            }
        } else {
            currentSong = nil
            currentIndex = nil
        }
        hasQueue = player.queue.currentEntry != nil || !player.queue.entries.isEmpty
    }
}
