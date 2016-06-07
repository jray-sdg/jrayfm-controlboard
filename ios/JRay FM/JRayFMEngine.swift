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
    
    private static let dataDirectory = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first!
    
    private static let dataFile = dataDirectory.URLByAppendingPathComponent("jrayFMLibrary")
    
    override init() {
        super.init()
        
        self.loadState()
    }
    
    private func loadState() {
        if let state = NSKeyedUnarchiver.unarchiveObjectWithFile(JRayFMEngine.dataFile.path!) as? EngineState {
            var entities = [MPMediaItem]()
            for libraryEntry in state.library {
                let query = MPMediaQuery.songsQuery()
                query.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(unsignedLongLong: libraryEntry), forProperty: MPMediaItemPropertyPersistentID))
                if let entity = query.items?.first! {
                    entities.append(entity)
                }
            }
            self.addItemsToLibraryInternal(entities)
        }
    }
    
    private func saveState() {
        NSKeyedArchiver.archiveRootObject(EngineState(libraryState: self.library.flatMap({ $0.1 }).map({ $0.id }))!, toFile: JRayFMEngine.dataFile.path!)
    }
    
    func addItemsToLibrary(items: [MPMediaItem]) {
        let itemsAdded = self.addItemsToLibraryInternal(items)
        
        if itemsAdded {
            self.library.sortInPlace({ $0.0 < $1.0 })
            
            for x in 0..<self.library.count {
                self.library[x].1.sortInPlace({ (s1, s2) in
                    let artistCompare = s1.artist.localizedCaseInsensitiveCompare(s2.artist)
                    if artistCompare != NSComparisonResult.OrderedSame {
                        return artistCompare == NSComparisonResult.OrderedAscending
                    }
                    return s1.name.localizedCaseInsensitiveCompare(s2.name) == NSComparisonResult.OrderedAscending
                })
            }
            
            self.saveState()
        }
    }
    
    private func addItemsToLibraryInternal(items: [MPMediaItem]) -> Bool {
        var itemsAdded = false
        for item in items {
            let entry = LibraryEntry(mediaItem: item)
            if !library.contains({ $0.1.contains({ $0.id == entry.id })}) {
                itemsAdded = true
                
                let sectionName = self.getSectionForEntry(entry)
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
    
    private let letterSet = NSCharacterSet.letterCharacterSet()
    
    private func getSectionForEntry(entry: LibraryEntry) -> String {
        let section = entry.artist.unicodeScalars.first!
        if letterSet.longCharacterIsMember(section.value) {
            let sectionString = section.escape(asASCII: false)
            return sectionString.uppercaseString
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
        self.library[section].1.removeAtIndex(index)
        self.saveState()
    }
    
    func generatePlaylist() {
        self.playlist.removeAll()
        
        let (largestGroup, groupedSongs) = JRayFMEngine.groupLibraryEntries(self.library.flatMap({ $0.1 }))
        
        var filledPlaylists = [[LibraryEntry]]()
        for (_, group) in groupedSongs {
            filledPlaylists.append(JRayFMEngine.fillList(group, length: largestGroup))
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
                let nextItem = slice.removeAtIndex(next)
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
            let nextItem = localBumperCollection.removeAtIndex(next)
            self.playlist.insert(nextItem, atIndex: pointer)
            
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
            
            if groupedSongs[libraryItem.artist]?.count > largestGroup {
                largestGroup = groupedSongs[libraryItem.artist]!.count
            }
        }
        return (largestGroup, groupedSongs)
    }
    
    private static func fillList(entries: [LibraryEntry], length: Int) -> [LibraryEntry] {
        let invert = entries.count > Int(Double(length) / 2)
        let ones = invert ? length - entries.count : entries.count
        var bitmap = [Bool](count: length, repeatedValue: false)
        
        if ones > 0 {
            var remaining = length
            for x in (1...ones).reverse() {
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
                let head = bitmap.removeAtIndex(0)
                bitmap.append(head)
            }
        }
        
        var localEntries = entries
        var filledPlaylist = [LibraryEntry]()
        for x in bitmap {
            if x {
                let randomIndex = Int(arc4random_uniform(UInt32(localEntries.count)))
                let randomEntry = localEntries.removeAtIndex(randomIndex)
                filledPlaylist.append(randomEntry)
            }
            else {
                filledPlaylist.append(LibraryEntry())
            }
        }
        
        return filledPlaylist
    }
    
    private static func getStationCollectons() -> ([LibraryEntry], [LibraryEntry]) {
        let songsQuery = MPMediaQuery.songsQuery()
        let artistFilter = MPMediaPropertyPredicate(value: "Jonathan Ray", forProperty: MPMediaItemPropertyArtist)
        songsQuery.addFilterPredicate(artistFilter)
        var bumperCollection = [LibraryEntry]()
        var signoffCollection = [LibraryEntry]()
        for item in songsQuery.items! {
            if let itemComments = item.comments {
                if itemComments.containsString("JRay-FM Bumper") {
                    bumperCollection.append(LibraryEntry(mediaItem: item))
                }
                else if itemComments.containsString("JRay-FM Sign-off") {
                    signoffCollection.append(LibraryEntry(mediaItem: item))
                }
            }
        }
        return (bumperCollection, signoffCollection)
    }
    
    func startPlaylist() {
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        let mediaItems = self.playlist.map(
            { (libraryEntry) -> MPMediaItem in
                let query = MPMediaQuery.songsQuery()
                query.addFilterPredicate(MPMediaPropertyPredicate(value: NSNumber(unsignedLongLong: libraryEntry.id), forProperty: MPMediaItemPropertyPersistentID))
                return query.items!.first!
            })
        let mediaItemCollection = MPMediaItemCollection(items: mediaItems)
        musicPlayer.setQueueWithItemCollection(mediaItemCollection)
        
        musicPlayer.play()
    }
    
    func getPlaylistItemCount() -> Int {
        return self.playlist.count
    }
    
    func getPlaylistItemAtIndex(index: Int) -> LibraryEntry {
        return self.playlist[index]
    }
}
