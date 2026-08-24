//
//  PlaylistGenerator.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import Foundation

enum PlaylistGenerator {
    static func generate(from songs: [LibrarySong]) -> [LibrarySong] {
        let (largestGroup, groupedSongs) = groupSongs(songs)
        
        var filledPlaylists = [[LibrarySong?]]()
        for (_, songGroup) in groupedSongs {
            filledPlaylists.append(fillList(songs: songGroup, length: largestGroup))
        }
        
        var playlist = [LibrarySong]()
        
        for sliceIndex in 0..<largestGroup {
            var slice = [LibrarySong]()
            for filledPlaylist in filledPlaylists {
                if let song = filledPlaylist[sliceIndex] {
                    slice.append(song)
                }
            }
            
            for _ in 0..<slice.count {
                let next = Int(arc4random_uniform(UInt32(slice.count)))
                let nextSong = slice.remove(at: next)
                playlist.append(nextSong)
            }
        }
        
        // TODO: bumpers
        // TODO: signoff
        
        return playlist
    }
    
    private static func groupSongs(_ songs: [LibrarySong]) -> (Int, [String : [LibrarySong]]) {
        var groupedSongs = [String : [LibrarySong]]()
        var largestGroup = 0
        for song in songs {
            let key = song.artistName
            if var songs = groupedSongs[key] {
                songs.append(song)
                groupedSongs[key] = songs
                largestGroup = max(songs.count, largestGroup)
            } else {
                groupedSongs[key] = [song]
                largestGroup = max(1, largestGroup)
            }
        }
        return (largestGroup, groupedSongs)
    }
    
    private static func fillList(songs: [LibrarySong], length: Int) -> [LibrarySong?] {
        let invert = songs.count > Int(Double(length) / 2)
        let ones = invert ? length - songs.count : songs.count
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
        
        var localEntries = songs
        var filledPlaylist = [LibrarySong?]()
        for x in bitmap {
            if x {
                let randomIndex = Int(arc4random_uniform(UInt32(localEntries.count)))
                let randomEntry = localEntries.remove(at: randomIndex)
                filledPlaylist.append(randomEntry)
            }
            else {
                filledPlaylist.append(nil)
            }
        }
        
        return filledPlaylist
    }
}
