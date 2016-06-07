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

    private var engine: JRayFMEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.engine = appDelegate.engine
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addLibraryItem(sender: AnyObject) {
        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.Music)
        mediaPicker.allowsPickingMultipleItems = true
        mediaPicker.showsCloudItems = true
        mediaPicker.delegate = self
        mediaPicker.prompt = "Add songs to library"
        
        self.presentViewController(mediaPicker, animated: true, completion: nil)
    }

    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        self.dismissViewControllerAnimated(true, completion: nil)
        engine.addItemsToLibrary(mediaItemCollection.items)
        tableView.reloadData()
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return engine.getSectionCount()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return engine.getSectionTitle(section)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return engine.getSectionTitles()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engine.getItemCount(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let entry = engine.getItemAtIndex(indexPath.section, index: indexPath.item)
        cell.textLabel?.text = entry.name
        cell.detailTextLabel?.text = entry.artist
        cell.imageView?.image = entry.image
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            engine.removeItemAtIndex(indexPath.section, index: indexPath.item)
            tableView.reloadData()
        }
    }
}

