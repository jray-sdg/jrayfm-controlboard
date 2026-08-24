//
//  LibraryManagementSheet.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import MusicKit
import SwiftUI
import SwiftData

struct LibraryManagementSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \LibrarySong.addedDate, order: .reverse)
    private var librarySongs: [LibrarySong]

    private enum Tab {
        case mySongs, addSongs
    }
    @State private var selectedTab: Tab = .mySongs

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedTab) {
                    Text("My Songs").tag(Tab.mySongs)
                    Text("Add Songs").tag(Tab.addSongs)
                }
                .pickerStyle(.segmented)
                .padding()

                switch selectedTab {
                case .mySongs:
                    MySongsTab(songs: librarySongs, modelContext: modelContext)
                case .addSongs:
                    AddSongsTab(existingSongs: librarySongs, modelContext: modelContext)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - My Songs

private struct MySongsTab: View {
    let songs: [LibrarySong]
    let modelContext: ModelContext

    var body: some View {
        if songs.isEmpty {
            ContentUnavailableView(
                "No Songs Yet",
                systemImage: "music.note.list",
                description: Text("Add songs from the \"Add Songs\" tab to build your shuffle pool.")
            )
        } else {
            List {
                ForEach(songs) { song in
                    HStack {
                        AsyncImage(url: song.artworkUrl) {
                            image in image.image?.resizable().aspectRatio(contentMode: .fit)
                        }
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(song.title)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(songs[index])
                    }
                }
            }
        }
    }
}

// MARK: - Add Songs

private struct AddSongsTab: View {
    let existingSongs: [LibrarySong]
    let modelContext: ModelContext

    @State private var viewModel = AddSongsViewModel()
    @State private var searchTerm = ""

    var body: some View {
        VStack {
            if viewModel.isSearching {
                ProgressView()
                    .frame(maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .padding()
            } else if viewModel.searchResults.isEmpty && !searchTerm.isEmpty {
                ContentUnavailableView.search(text: searchTerm)
            } else {
                List(viewModel.searchResults) { song in
                    SongResultRow(
                        song: song,
                        isAdded: LibrarySongFactory.isInLibrary(song, existing: existingSongs),
                        onToggle: { toggle(song) }
                    )
                }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search your library")
        .task(id: searchTerm) {
            // Lightweight debounce so we don't fire a request per keystroke.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await viewModel.search(term: searchTerm)
        }
    }

    private func toggle(_ song: Song) {
        if let existing = existingSongs.first(where: { $0.musicKitId == song.id.rawValue }) {
            modelContext.delete(existing)
        } else {
            let newSong = LibrarySongFactory.makeLibrarySong(from: song)
            modelContext.insert(newSong)
        }
    }
}

private struct SongResultRow: View {
    let song: Song
    let isAdded: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            artworkThumbnail
            
            VStack(alignment: .leading) {
                Text(song.title)
                Text(song.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggle) {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundStyle(isAdded ? .green : .accentColor)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var artworkThumbnail: some View {
        let size: CGFloat = 44

        if let artwork = song.artwork {
            ArtworkImage(artwork, width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary)
                .frame(width: size, height: size)
                .overlay {
                    Image(systemName: "music.note")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
        }
    }
}
