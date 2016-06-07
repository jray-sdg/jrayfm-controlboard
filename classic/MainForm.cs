using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using iTunesLib;

namespace JRayFMControlBoard
{
    public delegate void UpdateProgressDelegate(string text, int progress, int maxProgress);

    public partial class MainForm : Form
    {
        private Library library;
        private BackgroundWorker libraryLoader;
        private BackgroundWorker playlistGenerator;
        private List<string> playlistPool;

        private delegate void AddTreeNodeDelegate(TreeNode node);
        private AddTreeNodeDelegate addTreeNodeDelegate;
        private delegate void BeginProgressDelegate();
        private BeginProgressDelegate beginProgressDelegate;
        private delegate void EndProgressDelegate();
        private EndProgressDelegate endProgressDelegate;
        private UpdateProgressDelegate updateProgressDelegate;
        private DateTime playlistModifiedDate = DateTime.MinValue;

        private iTunesApp app = new iTunesApp();

        public MainForm()
        {
            InitializeComponent();
            playlistPool = new List<string>();
            listBox.DataSource = playlistPool;
            libraryLoader = new BackgroundWorker();
            libraryLoader.DoWork += new DoWorkEventHandler(libraryLoader_DoWork);
            libraryLoader.RunWorkerCompleted += new RunWorkerCompletedEventHandler(libraryLoader_RunWorkerCompleted);
            playlistGenerator = new BackgroundWorker();
            playlistGenerator.DoWork += new DoWorkEventHandler(playlistGenerator_DoWork);
            addTreeNodeDelegate = new AddTreeNodeDelegate(this.AddTreeNode);
            beginProgressDelegate = new BeginProgressDelegate(this.BeginProgress);
            endProgressDelegate = new EndProgressDelegate(this.EndProgress);
            updateProgressDelegate = new UpdateProgressDelegate(this.SetProgress);
        }

        void playlistGenerator_DoWork(object sender, DoWorkEventArgs e)
        {
            bool breakExecution = false;
            this.BeginProgress();
            this.SetProgress("Generating playlist", 0, 0);
            if (listBox.Items.Count > 0)
            {
                List<string> source = new List<string>();
                foreach (string str in listBox.Items)
                {
                    source.Add(str);
                }
                source = Engine.ShuffleList(source);
                List<Song> playlist = new List<Song>();
                foreach (string key in source)
                {
                    if (playlist.Count % 4 == 0)
                    {
                        playlist.Add(library.GetBumper());
                    }
                    playlist.Add(library.GetTrack(key));
                    if (playlist[playlist.Count - 1] == null)
                    {
                        MessageBox.Show(string.Format("{0} does not match a track in the iTunes library", key));
                        breakExecution = true;
                        break;
                    }
                }
                if (library.SignoffFound)
                {
                    playlist.Add(library.GetSignoff());
                }
                if (!breakExecution)
                {
                    string dateString = DateTime.Now.ToString("M/d/yy H:mm:ss");
                    int playlistCount = 1;
                    if (this.limitCheckBox.Checked)
                    {
                        playlistCount = (int)Math.Ceiling(playlist.Count / this.limitNumericUpDown.Value);
                    }
                    List<IITUserPlaylist> itplaylists = new List<IITUserPlaylist>();
                    for (int x = 0; x < playlistCount; x++)
                    {
                        itplaylists.Add((IITUserPlaylist)app.CreatePlaylist("JRay-FM " + dateString + (playlistCount > 1 ? string.Format(" {0}/{1}", x + 1, playlistCount) : string.Empty)));
                    }
                    int trackCount = 0;
                    int playlistIndex = 0;
                    foreach (Song track in playlist)
                    {
                        itplaylists[playlistIndex].AddFile(track.Path);
                        trackCount++;
                        if (playlistIndex < playlistCount - 1 && trackCount >= this.limitNumericUpDown.Value)
                        {
                            trackCount = 0;
                            playlistIndex++;
                        }
                    }
                }
            }
            this.EndProgress();
        }

        void libraryLoader_DoWork(object sender, DoWorkEventArgs e)
        {
            this.BeginProgress();
            library = new Library(SetProgress, app);
            Dictionary<string, Dictionary<string, Dictionary<string, Song>>> tracks = new Dictionary<string, Dictionary<string, Dictionary<string, Song>>>();
            foreach (Song track in library.GetTracks())
            {
                if (!tracks.ContainsKey(track.ArtistName))
                {
                    tracks.Add(track.ArtistName, new Dictionary<string, Dictionary<string, Song>>());
                }
                if (!tracks[track.ArtistName].ContainsKey(track.AlbumName))
                {
                    tracks[track.ArtistName].Add(track.AlbumName, new Dictionary<string, Song>());
                }
                tracks[track.ArtistName][track.AlbumName].Add(track.GetTracklistString(), track);
            }
            string[] artists = tracks.Keys.ToArray();
            Array.Sort<string>(artists);
            foreach (string artist in artists)
            {
                string[] albums = tracks[artist].Keys.ToArray();
                Array.Sort<string>(albums);
                TreeNode[] childs = new TreeNode[albums.Length];
                int counter = 0;
                foreach (string album in albums)
                {
                    string[] trackNumbers = tracks[artist][album].Keys.ToArray();
                    Array.Sort<string>(trackNumbers);
                    TreeNode[] smallerChilds = new TreeNode[trackNumbers.Length];
                    int smallerCounter = 0;
                    foreach (string trackNumber in trackNumbers)
                    {
                        smallerChilds[smallerCounter++] = new TreeNode(((Song)tracks[artist][album][trackNumber]).GetTracklistString());
                    }
                    childs[counter++] = new TreeNode(album, smallerChilds);
                }
                this.AddTreeNode(new TreeNode(artist, childs));
            }
            this.EndProgress();
        }

        void libraryLoader_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            if (!e.Cancelled && e.Error == null)
            {
                treeView.Enabled = true;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            libraryLoader.RunWorkerAsync();
            if (File.Exists("jrayfmlibrary.xml"))
            {
                XmlDocument settings = new XmlDocument();
                settings.Load("jrayfmlibrary.xml");
                foreach (XmlNode node in settings["jrayfm"].ChildNodes)
                {
                    switch (node.Name)
                    {
                        case "listKey":
                            playlistPool.Add(node.InnerText);
                            break;
                        case "playlistLimit":
                            int limit = int.Parse(node.InnerText);
                            if (limit < 0)
                            {
                                this.limitCheckBox.Checked = false;
                                this.limitNumericUpDown.Enabled = false;
                            }
                            else
                            {
                                this.limitCheckBox.Checked = true;
                                this.limitNumericUpDown.Enabled = true;
                                this.limitNumericUpDown.Value = limit;
                            }
                            break;
                        case "lastModified":
                            try
                            {
                                this.playlistModifiedDate = DateTime.FromBinary(long.Parse(node.InnerText));
                            }
                            catch
                            {
                                this.playlistModifiedDate = DateTime.MinValue;
                            }
                            this.UpdateTimestampLabel();
                            break;
                    }
                }
                playlistPool.Sort();
                this.RefreshPlaylistList();
            }
        }

        private void UpdateTimestampLabel()
        {
            timestampLabel.Text = string.Format("Playlist Last Modified: {0}", this.playlistModifiedDate.ToString());
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            XmlTextWriter writer = new XmlTextWriter("jrayfmlibrary.xml", Encoding.UTF8);
            writer.WriteStartDocument();
            writer.WriteStartElement("jrayfm");
            writer.WriteElementString("lastModified", playlistModifiedDate.ToBinary().ToString());
            writer.WriteElementString("playlistLimit", (this.limitCheckBox.Checked ? this.limitNumericUpDown.Value : -1).ToString("F0"));
            foreach (string key in playlistPool)
            {
                writer.WriteElementString("listKey", key);
            }
            writer.WriteEndElement();
            writer.WriteEndDocument();
            writer.Close();
        }

        private void generateButton_Click(object sender, EventArgs e)
        {
            playlistGenerator.RunWorkerAsync();
        }

        private void addButton_Click(object sender, EventArgs e)
        {
            this.AddSelectedItemToList();
            this.playlistModifiedDate = DateTime.Now;
            this.UpdateTimestampLabel();
        }

        private void AddSelectedItemToList()
        {
            if (treeView.Enabled && treeView.SelectedNode != null)
            {
                string[] trackParts = treeView.SelectedNode.FullPath.Split(treeView.PathSeparator.ToCharArray());
                if (trackParts.Length == 3)
                {
                    playlistPool.Add(library.GetTrack(trackParts[0], trackParts[1], trackParts[2]).ToString());
                    playlistPool.Sort();
                    this.RefreshPlaylistList();
                }
            }
        }

        private void removeButton_Click(object sender, EventArgs e)
        {
            if (listBox.SelectedItem != null)
            {
                playlistPool.Remove(listBox.SelectedItem.ToString());
                this.RefreshPlaylistList();
                this.playlistModifiedDate = DateTime.Now;
                this.UpdateTimestampLabel();
            }
        }

        private void AddTreeNode(TreeNode node)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(this.addTreeNodeDelegate, node);
            }
            else
            {
                treeView.Nodes.Add(node);
            }
        }

        private void treeView_DoubleClick(object sender, EventArgs e)
        {
            this.AddSelectedItemToList();
        }

        private void BeginProgress()
        {
            if (this.InvokeRequired)
            {
                this.Invoke(this.beginProgressDelegate);
            }
            else
            {
                this.progressBar.Visible = true;
                this.progressLabel.Visible = true;
                this.addButton.Enabled = false;
                this.removeButton.Enabled = false;
                this.generateButton.Enabled = false;
                this.limitCheckBox.Enabled = false;
                this.limitNumericUpDown.Enabled = false;
            }
        }

        private void EndProgress()
        {
            if (this.InvokeRequired)
            {
                this.Invoke(this.endProgressDelegate);
            }
            else
            {
                this.progressBar.Visible = false;
                this.progressLabel.Visible = false;
                this.addButton.Enabled = true;
                this.removeButton.Enabled = true;
                this.generateButton.Enabled = true;
                this.limitCheckBox.Enabled = true;
                this.limitNumericUpDown.Enabled = this.limitCheckBox.Checked;
            }
        }

        private void SetProgress(string text, int progress, int maxProgress)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(this.updateProgressDelegate, text, progress, maxProgress);
            }
            else
            {
                this.progressLabel.Text = text;
                if (maxProgress == 0)
                {
                    this.progressBar.Style = ProgressBarStyle.Marquee;
                }
                else
                {
                    this.progressBar.Style = ProgressBarStyle.Continuous;
                    this.progressBar.Maximum = maxProgress;
                    this.progressBar.Value = progress;
                }
            }
        }

        private void RefreshPlaylistList()
        {
            CurrencyManager cm = (CurrencyManager)BindingContext[playlistPool];
            cm.Refresh();
        }

        private void limitCheckBox_CheckedChanged(object sender, EventArgs e)
        {
            this.limitNumericUpDown.Enabled = this.limitCheckBox.Checked;
        }
    }
}
