using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using iTunesLib;

namespace JRayFMControlBoard
{
    class Library
    {
        private Dictionary<string, Song> trackList;
        private Dictionary<string, Song> bumperList;
        private Dictionary<string, Song> signoffList;

        private Dictionary<string, int> bumperReturnCount = null;

        private UpdateProgressDelegate updateProgress;
        private iTunesApp itunesApp;

        private static Random randomer = new Random();

        public bool SignoffFound { get { return this.signoffList.Count > 0; } }

        public Library(UpdateProgressDelegate progressUpdateDelegate, iTunesApp app)
        {
            trackList = new Dictionary<string, Song>();
            bumperList = new Dictionary<string, Song>();
            signoffList = new Dictionary<string, Song>();
            itunesApp = app;
            updateProgress = progressUpdateDelegate;
            this.CrawlFiles();
        }

        private void CrawlFiles()
        {
            /*int count = 0;
            int total = Directory.GetFiles(path, "*", SearchOption.AllDirectories).Length;
            foreach (string file in Directory.EnumerateFiles(path, "*", SearchOption.AllDirectories))
            {
                if (file.EndsWith(".m4a", StringComparison.CurrentCultureIgnoreCase) || file.EndsWith(".mp3", StringComparison.CurrentCultureIgnoreCase))
                {
                    TagLib.File metadata = TagLib.File.Create(file);
                    Song newSong = new Song(metadata.Tag.Title, (!string.IsNullOrEmpty(metadata.Tag.FirstPerformer) ? metadata.Tag.FirstPerformer : metadata.Tag.FirstAlbumArtist), metadata.Tag.Album, (int)metadata.Tag.Track, Convert.ToInt32(metadata.Properties.Duration.TotalSeconds), file);
                    if (string.IsNullOrEmpty(metadata.Tag.Comment) || !metadata.Tag.Comment.Contains("JRay-FM Bumper"))
                    {
                        trackList.Add(newSong.ToString(), newSong);
                    }
                    else
                    {
                        bumperList.Add(newSong.ToString(), newSong);
                    }
                    //this.updateProgress(string.Format("Examining file {0} of {1}", count, total), ++count, total);
                }
            }*/
            int count = 0;
            IITTrackCollection tracks = itunesApp.LibraryPlaylist.Tracks;
            foreach (IITTrack track in tracks)
            {
                this.updateProgress(string.Format("Scanning track {0} of {1}", ++count, tracks.Count), count, tracks.Count);
                if (track.Kind != ITTrackKind.ITTrackKindFile || track.Album == null || ((IITFileOrCDTrack)track).VideoKind != ITVideoKind.ITVideoKindNone || ((IITFileOrCDTrack)track).Podcast == true || track.Genre == "Books & Spoken")
                {
                    continue;
                }
                Song newSong = new Song(track.Name, (!string.IsNullOrEmpty(track.Artist) ? track.Artist : ((IITFileOrCDTrack)track).AlbumArtist), track.Album, track.TrackNumber, track.Duration, ((IITFileOrCDTrack)track).Location);
                if (string.IsNullOrEmpty(track.Comment) || (!track.Comment.Contains("JRay-FM Bumper") && !track.Comment.Contains("JRay-FM Sign-off")))
                {
                    trackList.Add(newSong.ToString(), newSong);
                }
                else if (!track.Comment.Contains("JRay-FM Sign-off"))
                {
                    bumperList.Add(newSong.ToString(), newSong);
                }
                else
                {
                    signoffList.Add(newSong.ToString(), newSong);
                }
            }
        }

        public IEnumerable<Song> GetTracks()
        {
            foreach (Song track in trackList.Values)
            {
                yield return track;
            }
        }

        public Song GetTrack(string artist, string album, string tracklistName)
        {
            string key = artist + "|" + album + "|" + tracklistName;
            return this.GetTrack(key);
        }

        public Song GetTrack(string key)
        {
            if (trackList.ContainsKey(key))
            {
                return trackList[key];
            }
            return null;
        }

        public Song GetBumper()
        {
            Song ret = null;
            if (bumperReturnCount == null)
            {
                bumperReturnCount = new Dictionary<string, int>();
                foreach (Song bumper in bumperList.Values)
                {
                    bumperReturnCount.Add(bumper.ToString(), 0);
                }
            }
            int smallestCount = int.MaxValue;
            foreach (string key in bumperReturnCount.Keys)
            {
                if (bumperReturnCount[key] < smallestCount)
                {
                    smallestCount = bumperReturnCount[key];
                }
            }
            List<string> leastReturned = new List<string>();
            foreach (string key in bumperReturnCount.Keys)
            {
                if (bumperReturnCount[key] == smallestCount)
                {
                    leastReturned.Add(key);
                }
            }
            int select = randomer.Next(0, leastReturned.Count - 1);
            foreach (string key in leastReturned)
            {
                if (select == 0)
                {
                    ret = bumperList[key];
                    bumperReturnCount[key]++;
                }
                select--;
            }
            return ret;
        }

        public Song GetSignoff()
        {
            return signoffList.Values.ToList()[randomer.Next(0, signoffList.Count - 1)];
        }
    }
}
