using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace JRayFMControlBoard
{
    class Engine
    {
        #region Shuffle
        // Based on http://keyj.emphy.de/balanced-shuffle/
        public static List<string> ShuffleList(List<string> list)
        {
            Dictionary<string, List<string>> playlists = new Dictionary<string, List<string>>();
            int longestPlaylist = 0;
            foreach (string track in list)
            {
                string artist = track.Split('|')[0];
                if (!playlists.ContainsKey(artist))
                {
                    playlists.Add(artist, new List<string>());
                }
                playlists[artist].Add(track);
                if (playlists[artist].Count > longestPlaylist)
                {
                    longestPlaylist = playlists[artist].Count;
                }
            }
            Dictionary<string, List<string>> filledPlaylists = new Dictionary<string, List<string>>();
            foreach (KeyValuePair<string, List<string>> playlist in playlists)
            {
                filledPlaylists.Add(playlist.Key, Fill(playlist.Value, longestPlaylist));
            }
            return Merge(filledPlaylists, longestPlaylist);
        }

        private static List<string> Fill(List<string> playlist, int length)
        {
            Random r = new Random();
            int ones = playlist.Count;
            bool invert = ones > length / 2;
            if (invert)
            {
                ones = length - ones;
            }
            int[] bitmap = new int[length];
            for (int x = 0; x < bitmap.Length; x++)
            {
                bitmap[x] = 0;
            }
            int remaining = length;
            for (int x = ones; x > 0; x--)
            {
                bitmap[length - remaining] = 1;
                double skip = remaining / x;
                skip = ((int)0.9 * skip) + (r.NextDouble() * (((int)1.1 * skip) - (((int)0.9 * skip) + 2)));
                remaining -= (int)Math.Min(Math.Max(1, skip), remaining - x + 1);
            }
            if (invert)
            {
                for (int x = 0; x < bitmap.Length; x++)
                {
                    bitmap[x] = 1 - bitmap[x];
                }
            }
            int offset = r.Next(length);
            List<string> localPlaylist = new List<string>(playlist);
            List<string> filledPlaylist = new List<string>();
            int pointer = offset;
            do
            {
                if (bitmap[pointer] == 1)
                {
                    int next = r.Next(0, localPlaylist.Count - 1);
                    filledPlaylist.Add(localPlaylist[next]);
                    localPlaylist.RemoveAt(next);
                }
                else
                {
                    filledPlaylist.Add(string.Empty);
                }
                pointer++;
                if (pointer > bitmap.Length - 1)
                {
                    pointer = 0;
                }
            } while (pointer != offset);
            return filledPlaylist;
        }

        private static List<string> Merge(Dictionary<string, List<string>> playlists, int length)
        {
            List<string> mergedList = new List<string>();
            Random r = new Random();
            for (int x = 0; x < length; x++)
            {
                List<string> tempList = new List<string>();
                List<string> listToAdd = new List<string>();
                foreach (List<string> playlist in playlists.Values)
                {
                    if (!string.IsNullOrEmpty(playlist[x]))
                    {
                        tempList.Add(playlist[x]);
                    }
                }
                while (tempList.Count > 0)
                {
                    int next = r.Next(0, tempList.Count - 1);
                    listToAdd.Add(tempList[next]);
                    tempList.RemoveAt(next);
                }
                if (mergedList.Count > 0 && listToAdd.Count > 0 && mergedList[mergedList.Count - 1].Split('|')[0] == listToAdd[0].Split('|')[0])
                {
                    listToAdd.Add(listToAdd[0]);
                    listToAdd.RemoveAt(0);
                }
                mergedList.AddRange(listToAdd);
            }
            return mergedList;
        }
        #endregion
    }
}
