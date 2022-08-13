//
//  SecondViewController.swift
//  JRay FM
//
//  Created by Jonathan Ray on 4/10/16.
//  Copyright © 2016 Jonathan Ray. All rights reserved.
//

import MediaPlayer
import UIKit

class SecondViewController: UITableViewController, MPMediaPickerControllerDelegate {
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    private var engine: JRayFMEngine!
    
    private var defaultEntryImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.engine = appDelegate.engine
        
        self.defaultEntryImage = UIImage(systemName: "tv.music.note.fill")
        
        self.editButtonVisible(animate: false);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addLibraryItem(_ sender: AnyObject) {
        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.music)
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.showsCloudItems = true
        mediaPicker.delegate = self
        mediaPicker.prompt = "Add songs to library"
        
        self.present(mediaPicker, animated: true, completion: nil)
    }

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.dismiss(animated: true, completion: nil)
        engine.addItemsToLibrary(items: mediaItemCollection.items)
        tableView.reloadData()
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return engine.getSectionCount()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return engine.getSectionTitle(section: section)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return engine.getSectionTitles()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engine.getItemCount(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = engine.getItemAtIndex(section: indexPath.section, index: indexPath.item)
        cell.textLabel?.text = entry.name
        cell.detailTextLabel?.text = entry.artist
        
        if entry.image != nil {
            cell.imageView?.image = entry.image
        }
        else {
            cell.imageView?.image = self.defaultEntryImage
            cell.imageView?.tintColor = UIColor.label
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            engine.removeItemAtIndex(section: indexPath.section, index: indexPath.item)
            tableView.reloadData()
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.doneButtonVisible(animate: true)
        tableView.setEditing(true, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.editButtonVisible(animate: true)
        tableView.setEditing(false, animated: true)
    }
    
    func editButtonVisible(animate: Bool) {
        self.navigationItem.setLeftBarButtonItems([editButton], animated: animate)
    }
    
    func doneButtonVisible(animate:Bool) {
        self.navigationItem.setLeftBarButtonItems([doneButton], animated: animate)
    }
}

