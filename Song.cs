using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JRayFMControlBoard
{
    class Song
    {
        public string TrackName { get; protected set; }
        public string ArtistName { get; protected set; }
        public string AlbumName { get; protected set; }
        public string Path { get; protected set; }
        public int TrackNumber { get; protected set; }
        public int Length { get; protected set; }

        public Song(string name, string artist, string album, int number, int length, string path)
        {
            this.TrackName = name;
            this.ArtistName = artist;
            this.AlbumName = album;
            this.TrackNumber = number;
            this.Length = length;
            this.Path = path;
        }

        public override string ToString()
        {
            return this.ArtistName + "|" + this.AlbumName + "|" + this.GetTracklistString();
        }

        public string GetTracklistString()
        {
            return this.TrackNumber.ToString("00") + " - " + this.TrackName;
        }
    }
}
