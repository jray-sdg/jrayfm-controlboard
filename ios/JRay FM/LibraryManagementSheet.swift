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

    @State private var isMusicPickerPresented = false
    @State private var selectedSongs: MusicItemCollection<Song> = []

    var body: some View {
        NavigationStack {
            LibrarySongsList(songs: librarySongs, modelContext: modelContext)
                .safeAreaInset(edge: .bottom) {
                    Button {
                        selectedSongs = []
                        isMusicPickerPresented = true
                    } label: {
                        Label("Add Songs", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .musicPicker(
                    isPresented: $isMusicPickerPresented,
                    title: Text("Add Songs"),
                    selection: $selectedSongs
                )
                .onChange(of: isMusicPickerPresented) { wasPresented, isPresented in
                    guard wasPresented, !isPresented else { return }
                    addSelectedSongs()
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

    private func addSelectedSongs() {
        var existingSongsByID = Dictionary(uniqueKeysWithValues: librarySongs.map { ($0.musicKitId, $0) })

        for song in selectedSongs {
            if let existingSong = existingSongsByID[song.id.rawValue] {
                if existingSong.artworkData == nil {
                    existingSong.artworkData = LibrarySongFactory.encodedArtwork(for: song)
                }
                continue
            }

            let librarySong = LibrarySongFactory.makeLibrarySong(from: song)
            modelContext.insert(librarySong)
            existingSongsByID[librarySong.musicKitId] = librarySong
        }

        selectedSongs = []
    }
}

private struct LibrarySongsList: View {
    let songs: [LibrarySong]
    let modelContext: ModelContext

    private var groupedSongs: [(letter: String, songs: [LibrarySong])] {
        let sortedSongs = songs.sorted {
            let artistComparison = $0.artistName.localizedStandardCompare($1.artistName)
            if artistComparison != .orderedSame {
                return artistComparison == .orderedAscending
            }
            return $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
        let groups = Dictionary(grouping: sortedSongs, by: Self.artistInitial)

        return groups.keys.sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        }.map { (letter: $0, songs: groups[$0] ?? []) }
    }

    var body: some View {
        if songs.isEmpty {
            ContentUnavailableView(
                "No Songs Yet",
                systemImage: "music.note.list",
                description: Text("Add songs to build your shuffle pool.")
            )
        } else {
            List {
                ForEach(groupedSongs, id: \.letter) { group in
                    Section(group.letter) {
                        ForEach(group.songs) { song in
                            HStack {
                                artworkView(for: song)
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
                                modelContext.delete(group.songs[index])
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func artworkView(for song: LibrarySong) -> some View {
        if let artworkData = song.artworkData,
           let artwork = try? JSONDecoder().decode(Artwork.self, from: artworkData) {
            ArtworkImage(artwork, width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else if let artworkUrl = song.artworkUrl,
                  artworkUrl.scheme == "https" || artworkUrl.scheme == "http" {
            AsyncImage(url: artworkUrl) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                artworkPlaceholder
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            artworkPlaceholder
        }
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.quaternary)
            .overlay {
                Image(systemName: "music.note")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
    }

    nonisolated private static func artistInitial(for song: LibrarySong) -> String {
        guard let firstCharacter = song.artistName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .first,
              firstCharacter.isLetter else {
            return "#"
        }
        return String(firstCharacter).uppercased()
    }
}
