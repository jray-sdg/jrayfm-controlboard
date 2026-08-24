//
//  NowPlayingView.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import SwiftUI
import SwiftData
import MusicKit

struct NowPlayingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var librarySongs: [LibrarySong]

    @State private var playback = PlaybackController(ApplicationMusicPlayer.shared)
    @State private var showingLibrarySheet = false
    @State private var isGenerating = false
    @State private var hasAttemptedResume = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let error = playback.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer()

                content

                Spacer()

                Button {
                    Task { await shuffleAndPlay() }
                } label: {
                    Label(
                        isGenerating ? "Generating…" : "New Playlist",
                        systemImage: "shuffle"
                    )
                }
                .buttonStyle(.bordered)
                .disabled(librarySongs.isEmpty || isGenerating)
            }
            .padding()
            .navigationTitle("88.3 JRay FM")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Library") {
                        showingLibrarySheet = true
                    }
                }
            }
            .sheet(isPresented: $showingLibrarySheet) {
                LibraryManagementSheet()
            }
            .task {
                guard !hasAttemptedResume else { return }
                hasAttemptedResume = true
                await resumeIfPossible()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let song = playback.currentSong {
            VStack(spacing: 24) {
                artworkView(for: song)
                
                VStack(spacing: 8) {
                    Text(song.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text(song.artistName)
                        .foregroundStyle(.secondary)
                }

                if let index = playback.currentIndex, let length = playback.queueLength {
                    Text("Track \(index + 1) of \(length)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                transportControls
            }
        } else if librarySongs.isEmpty {
            ContentUnavailableView(
                "Your Library Is Empty",
                systemImage: "music.note.list",
                description: Text("Add some songs first, then generate a playlist.")
            )
        } else {
            ContentUnavailableView(
                "No Playlist Yet",
                systemImage: "shuffle",
                description: Text("Tap \"New Playlist\" to get started.")
            )
        }
    }
    
    @ViewBuilder
    private func artworkView(for song: Song) -> some View {
        let size: CGFloat = 240

        if let artwork = song.artwork {
            ArtworkImage(artwork, width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "music.note")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                }
        }
    }

    private var transportControls: some View {
        HStack(spacing: 32) {
            Button {
                playback.skipToPrevious()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
            }

            Button {
                playback.togglePlayPause()
            } label: {
                Image(systemName: playback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
            }

            Button {
                playback.skipToNext()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
            }
            .disabled(!playback.canSkipForward)
        }
        .disabled(!playback.hasQueue)
    }

    // MARK: - Actions

    /// "Shuffle & Play": reads the library, generates a new order, resolves
    /// to MusicKit Song values preserving that order, and hands off to the
    /// controller. This is the one place SwiftData, the generator, and
    /// MusicKit all meet.
    private func shuffleAndPlay() async {
        isGenerating = true
        defer { isGenerating = false }

        let shuffledSongs = PlaylistGenerator.generate(from: librarySongs)
        let shuffledIDs = shuffledSongs.map(\.musicKitId)

        guard let resolved = await resolveSongs(musicKitIDs: shuffledIDs) else {
            playback.setError("Couldn't load songs for playback.")
            return
        }

        await playback.load(songs: resolved)
    }

    /// On launch, check for a persisted playlist and load it (without
    /// auto-playing) so the user sees their session ready to resume rather
    /// than an empty state, without audio starting unexpectedly.
    private func resumeIfPossible() async {
        guard let savedIDs = PlaylistStore.loadSongIDs(), !savedIDs.isEmpty else { return }
        let savedIndex = PlaylistStore.loadCurrentIndex()

        guard let resolved = await resolveSongs(musicKitIDs: savedIDs) else { return }
        await playback.loadWithoutPlaying(songs: resolved, startingAt: savedIndex)
    }

    /// Resolves MusicKit ID strings back to Song values via a library
    /// request, preserving the input order (MusicLibraryRequest does not
    /// guarantee result order matches the filter list).
    private func resolveSongs(musicKitIDs: [String]) async -> [Song]? {
        do {
            let ids = musicKitIDs.map { MusicItemID($0) }
            var request = MusicLibraryRequest<Song>()
            request.filter(matching: \.id, memberOf: ids)
            let response = try await request.response()

            let songsByID = Dictionary(uniqueKeysWithValues: response.items.map { ($0.id, $0) })
            return ids.compactMap { songsByID[$0] }
        } catch {
            return nil
        }
    }
}
