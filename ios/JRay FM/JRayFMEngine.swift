//
//  JRayFMEngine.swift
//  JRay FM
//
//  Created by Jonathan Ray on 4/19/16.
//  Copyright © 2016 Jonathan Ray. All rights reserved.
//

import MediaPlayer
import UIKit

class JRayFMEngine: NSObject {
    
    private var library = [(String, [LibraryEntry])]()
    
    private var playlist = [LibraryEntry]()
    
    private static let dataDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
    
    private static let dataFile = dataDirectory.appendingPathComponent("jrayFMLibrary")
    
    override init() {
        super.init()
        
        self.loadState()
    }
    
    private func loadState() {
        if let input = InputStream(fileAtPath: JRayFMEngine.dataFile.path) {
            input.open()
            
            if let state = try? JSONSerialization.jsonObject(with: input) {
                if let dictionary = state as? [String:Any] {
                    if let entries = dictionary["library"] as? [UInt64] {
                        var mediaEntities = [MPMediaItem]()
                        for entry in entries {
                            let query = MPMediaQuery.songs()
                            query.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(value: entry as UInt64), forProperty: MPMediaItemPropertyPersistentID))
                            if let entity = query.items?.first! {
                                mediaEntities.append(entity)
                            }
                        }
                        _ = self.addItemsToLibraryInternal(items: mediaEntities)
                    }
                }
            }
            
            input.close()
        }
    }
    
    private func saveState() {
        let entries = self.library.flatMap({ $0.1 }).map({ $0.id })
        let dictionary = ["library": entries]
        
        if let output = OutputStream(toFileAtPath: JRayFMEngine.dataFile.path, append: false) {
            output.open()
            
            var error : NSError?
            _ = JSONSerialization.writeJSONObject(dictionary, to: output, error: &error)
            
            output.close()
        }
    }
    
    func addItemsToLibrary(items: [MPMediaItem]) {
        let itemsAdded = self.addItemsToLibraryInternal(items: items)
        
        if itemsAdded {
            self.library.sort(by: { $0.0 < $1.0 })
            
            for x in 0..<self.library.count {
                self.library[x].1.sort(by: { (s1, s2) in
                    let artistCompare = s1.artist.localizedCaseInsensitiveCompare(s2.artist)
                    if artistCompare != ComparisonResult.orderedSame {
                        return artistCompare == ComparisonResult.orderedAscending
                    }
                    return s1.name.localizedCaseInsensitiveCompare(s2.name) == ComparisonResult.orderedAscending
                })
            }
            
            self.saveState()
        }
    }
    
    private func addItemsToLibraryInternal(items: [MPMediaItem]) -> Bool {
        var itemsAdded = false
        for item in items {
            let entry = LibraryEntry(mediaItem: item)
            if !library.contains(where: { $0.1.contains(where: { $0.id == entry.id })}) {
                itemsAdded = true
                
                let sectionName = self.getSectionForEntry(entry: entry)
                var foundSection = false
                for x in 0..<self.library.count {
                    if self.library[x].0 == sectionName {
                        foundSection = true
                        self.library[x].1.append(entry)
                    }
                }
                
                if !foundSection {
                    self.library.append((sectionName, [entry]))
                }
            }
        }
        return itemsAdded
    }
    
    private let letterSet = CharacterSet.letters
    
    private func getSectionForEntry(entry: LibraryEntry) -> String {
        let section = entry.artist.unicodeScalars.first!
        if letterSet.contains(UnicodeScalar(section.value)!) {
            let sectionString = section.escaped(asASCII: false)
            return sectionString.uppercased()
        }
        else {
            return "#"
        }
    }
    
    func getSectionTitles() -> [String] {
        return self.library.map({ $0.0 })
    }
    
    func getSectionCount() -> Int {
        return self.library.count
    }
    
    func getItemCount(section: Int) -> Int {
        return self.library[section].1.count
    }
    
    func getSectionTitle(section: Int) -> String {
        return self.library[section].0
    }
    
    func getItemAtIndex(section: Int, index: Int) -> LibraryEntry {
        return self.library[section].1[index]
    }
    
    func removeItemAtIndex(section: Int, index: Int) {
        self.library[section].1.remove(at: index)
        self.saveState()
    }
    
    func generatePlaylist() {
        self.playlist.removeAll()
        
        let (largestGroup, groupedSongs) = JRayFMEngine.groupLibraryEntries(library: self.library.flatMap({ $0.1 }))
        
        var filledPlaylists = [[LibraryEntry]]()
        for (_, group) in groupedSongs {
            filledPlaylists.append(JRayFMEngine.fillList(entries: group, length: largestGroup))
        }
        
        for sliceIndex in 0..<largestGroup {
            var slice = [LibraryEntry]()
            for filledPlaylist in filledPlaylists {
                if !filledPlaylist[sliceIndex].isEmpty() {
                    slice.append(filledPlaylist[sliceIndex])
                }
            }
            
            for _ in 0..<slice.count {
                let next = Int(arc4random_uniform(UInt32(slice.count)))
                let nextItem = slice.remove(at: next)
                self.playlist.append(nextItem)
            }
        }
        
        let (bumperCollection, signoffCollection) = JRayFMEngine.getStationCollectons()
        var localBumperCollection = [LibraryEntry]()
        var pointer = 0
        while pointer < self.playlist.count - 1 {
            if localBumperCollection.count == 0 {
                localBumperCollection = bumperCollection
            }
            
            let next = Int(arc4random_uniform(UInt32(localBumperCollection.count)))
            let nextItem = localBumperCollection.remove(at: next)
            self.playlist.insert(nextItem, at: pointer)
            
            pointer += 4
        }
        
        let selectedSignoffIndex = Int(arc4random_uniform(UInt32(signoffCollection.count)))
        let selectedSignoff = signoffCollection[selectedSignoffIndex]
        self.playlist.append(selectedSignoff)
    }
    
    private static func groupLibraryEntries(library: [LibraryEntry]) -> (Int, [String : [LibraryEntry]]) {
        var groupedSongs = [String : [LibraryEntry]]()
        var largestGroup = 0
        for libraryItem in library {
            if groupedSongs[libraryItem.artist] != nil {
                groupedSongs[libraryItem.artist]!.append(libraryItem)
            }
            else {
                groupedSongs[libraryItem.artist] = [libraryItem]
            }
            
            if groupedSongs[libraryItem.artist]!.count > largestGroup {
                largestGroup = groupedSongs[libraryItem.artist]!.count
            }
        }
        return (largestGroup, groupedSongs)
    }
    
    private static func fillList(entries: [LibraryEntry], length: Int) -> [LibraryEntry] {
        let invert = entries.count > Int(Double(length) / 2)
        let ones = invert ? length - entries.count : entries.count
        var bitmap = [Bool](repeating: false, count: length)
        
        if ones > 0 {
            var remaining = length
            for x in (1...ones).reversed() {
                bitmap[length - remaining] = true
                var skip = Double(remaining) / Double(x)
                let randomFactor = Double(arc4random_uniform(10000)) / 10000
                skip = (0.9 * skip) + (randomFactor * ((1.1 * skip) - ((0.9 * skip) + 2)))
                remaining -= Int(min(max(1, skip), Double(remaining) - Double(x) + 2))
            }
        }
        
        if invert {
            bitmap = bitmap.map({ !$0 })
        }
        
        let offset = Int(arc4random_uniform(UInt32(length)))
        if offset > 0 {
            for _ in 1...offset {
                let head = bitmap.remove(at: 0)
                bitmap.append(head)
            }
        }
        
        var localEntries = entries
        var filledPlaylist = [LibraryEntry]()
        for x in bitmap {
            if x {
                let randomIndex = Int(arc4random_uniform(UInt32(localEntries.count)))
                let randomEntry = localEntries.remove(at: randomIndex)
                filledPlaylist.append(randomEntry)
            }
            else {
                filledPlaylist.append(LibraryEntry())
            }
        }
        
        return filledPlaylist
    }
    
    private static func getStationCollectons() -> ([LibraryEntry], [LibraryEntry]) {
        let songsQuery = MPMediaQuery.songs()
        let artistFilter = MPMediaPropertyPredicate(value: "Jonathan Ray", forProperty: MPMediaItemPropertyArtist)
        songsQuery.addFilterPredicate(artistFilter)
        var bumperCollection = [LibraryEntry]()
        var signoffCollection = [LibraryEntry]()
        for item in songsQuery.items! {
            if let itemComments = item.comments {
                if itemComments.contains("JRay-FM Bumper") {
                    bumperCollection.append(LibraryEntry(mediaItem: item))
                }
                else if itemComments.contains("JRay-FM Sign-off") {
                    signoffCollection.append(LibraryEntry(mediaItem: item))
                }
            }
        }
        return (bumperCollection, signoffCollection)
    }
    
    func startPlaylist() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        let mediaItems = self.playlist.map(
            { (libraryEntry) -> MPMediaItem in
                let query = MPMediaQuery.songs()
                query.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(value: libraryEntry.id as UInt64), forProperty: MPMediaItemPropertyPersistentID))
                return query.items!.first!
            })
        let mediaItemCollection = MPMediaItemCollection(items: mediaItems)
        musicPlayer.setQueue(with: mediaItemCollection)
        
        musicPlayer.play()
    }
    
    func getPlaylistItemCount() -> Int {
        return self.playlist.count
    }
    
    func getPlaylistItemAtIndex(_ index: Int) -> LibraryEntry {
        return self.playlist[index]
    }
}
