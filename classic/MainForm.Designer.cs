namespace JRayFMControlBoard
{
    partial class MainForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.treeView = new System.Windows.Forms.TreeView();
            this.listBox = new System.Windows.Forms.ListBox();
            this.addButton = new System.Windows.Forms.Button();
            this.removeButton = new System.Windows.Forms.Button();
            this.generateButton = new System.Windows.Forms.Button();
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.progressLabel = new System.Windows.Forms.Label();
            this.timestampLabel = new System.Windows.Forms.Label();
            this.limitCheckBox = new System.Windows.Forms.CheckBox();
            this.limitNumericUpDown = new System.Windows.Forms.NumericUpDown();
            ((System.ComponentModel.ISupportInitialize)(this.limitNumericUpDown)).BeginInit();
            this.SuspendLayout();
            // 
            // treeView
            // 
            this.treeView.Enabled = false;
            this.treeView.Location = new System.Drawing.Point(12, 12);
            this.treeView.Name = "treeView";
            this.treeView.PathSeparator = "|";
            this.treeView.Size = new System.Drawing.Size(493, 511);
            this.treeView.TabIndex = 0;
            this.treeView.DoubleClick += new System.EventHandler(this.treeView_DoubleClick);
            // 
            // listBox
            // 
            this.listBox.FormattingEnabled = true;
            this.listBox.Location = new System.Drawing.Point(592, 12);
            this.listBox.Name = "listBox";
            this.listBox.Size = new System.Drawing.Size(477, 511);
            this.listBox.TabIndex = 1;
            // 
            // addButton
            // 
            this.addButton.Location = new System.Drawing.Point(511, 114);
            this.addButton.Name = "addButton";
            this.addButton.Size = new System.Drawing.Size(75, 23);
            this.addButton.TabIndex = 2;
            this.addButton.Text = "->";
            this.addButton.UseVisualStyleBackColor = true;
            this.addButton.Click += new System.EventHandler(this.addButton_Click);
            // 
            // removeButton
            // 
            this.removeButton.Location = new System.Drawing.Point(511, 143);
            this.removeButton.Name = "removeButton";
            this.removeButton.Size = new System.Drawing.Size(75, 23);
            this.removeButton.TabIndex = 3;
            this.removeButton.Text = "<-";
            this.removeButton.UseVisualStyleBackColor = true;
            this.removeButton.Click += new System.EventHandler(this.removeButton_Click);
            // 
            // generateButton
            // 
            this.generateButton.Location = new System.Drawing.Point(592, 529);
            this.generateButton.Name = "generateButton";
            this.generateButton.Size = new System.Drawing.Size(126, 23);
            this.generateButton.TabIndex = 5;
            this.generateButton.Text = "Generate Playlist...";
            this.generateButton.UseVisualStyleBackColor = true;
            this.generateButton.Click += new System.EventHandler(this.generateButton_Click);
            // 
            // progressBar
            // 
            this.progressBar.Location = new System.Drawing.Point(12, 529);
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(154, 23);
            this.progressBar.TabIndex = 6;
            this.progressBar.Visible = false;
            // 
            // progressLabel
            // 
            this.progressLabel.AutoSize = true;
            this.progressLabel.Location = new System.Drawing.Point(172, 534);
            this.progressLabel.Name = "progressLabel";
            this.progressLabel.Size = new System.Drawing.Size(48, 13);
            this.progressLabel.TabIndex = 7;
            this.progressLabel.Text = "Progress";
            this.progressLabel.Visible = false;
            // 
            // timestampLabel
            // 
            this.timestampLabel.Location = new System.Drawing.Point(724, 534);
            this.timestampLabel.Name = "timestampLabel";
            this.timestampLabel.Size = new System.Drawing.Size(337, 13);
            this.timestampLabel.TabIndex = 8;
            this.timestampLabel.Text = "Playlist Last Modified:";
            this.timestampLabel.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // limitCheckBox
            // 
            this.limitCheckBox.AutoSize = true;
            this.limitCheckBox.Location = new System.Drawing.Point(344, 534);
            this.limitCheckBox.Name = "limitCheckBox";
            this.limitCheckBox.Size = new System.Drawing.Size(125, 17);
            this.limitCheckBox.TabIndex = 9;
            this.limitCheckBox.Text = "Limit playlist length to";
            this.limitCheckBox.UseVisualStyleBackColor = true;
            this.limitCheckBox.CheckedChanged += new System.EventHandler(this.limitCheckBox_CheckedChanged);
            // 
            // limitNumericUpDown
            // 
            this.limitNumericUpDown.Enabled = false;
            this.limitNumericUpDown.Location = new System.Drawing.Point(467, 533);
            this.limitNumericUpDown.Maximum = new decimal(new int[] {
            500,
            0,
            0,
            0});
            this.limitNumericUpDown.Minimum = new decimal(new int[] {
            20,
            0,
            0,
            0});
            this.limitNumericUpDown.Name = "limitNumericUpDown";
            this.limitNumericUpDown.Size = new System.Drawing.Size(40, 20);
            this.limitNumericUpDown.TabIndex = 10;
            this.limitNumericUpDown.Value = new decimal(new int[] {
            20,
            0,
            0,
            0});
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1084, 564);
            this.Controls.Add(this.limitNumericUpDown);
            this.Controls.Add(this.limitCheckBox);
            this.Controls.Add(this.timestampLabel);
            this.Controls.Add(this.progressLabel);
            this.Controls.Add(this.progressBar);
            this.Controls.Add(this.generateButton);
            this.Controls.Add(this.removeButton);
            this.Controls.Add(this.addButton);
            this.Controls.Add(this.listBox);
            this.Controls.Add(this.treeView);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Form1";
            this.Text = "JRay FM Control Board";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.Load += new System.EventHandler(this.Form1_Load);
            ((System.ComponentModel.ISupportInitialize)(this.limitNumericUpDown)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TreeView treeView;
        private System.Windows.Forms.ListBox listBox;
        private System.Windows.Forms.Button addButton;
        private System.Windows.Forms.Button removeButton;
        private System.Windows.Forms.Button generateButton;
        private System.Windows.Forms.ProgressBar progressBar;
        private System.Windows.Forms.Label progressLabel;
        private System.Windows.Forms.Label timestampLabel;
        private System.Windows.Forms.CheckBox limitCheckBox;
        private System.Windows.Forms.NumericUpDown limitNumericUpDown;
    }
}

