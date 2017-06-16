//
//  FirstViewController.swift
//  JRay FM
//
//  Created by Jonathan Ray on 4/10/16.
//  Copyright © 2016 Jonathan Ray. All rights reserved.
//

import UIKit

class FirstViewController: UITableViewController {

    private var engine: JRayFMEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.engine = appDelegate.engine
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func generatePlaylistPressed(_ sender: AnyObject) {
        if engine.getPlaylistItemCount() > 0 {
            self.confirmPlaylistGeneration()
        }
        else {
            self.generatePlaylist()
        }
    }
    
    private func generatePlaylist() {
        self.engine.generatePlaylist()
        self.tableView.reloadData()
    }
    
    private func confirmPlaylistGeneration() {
        let confirm = UIAlertController(title: "Confirm generation", message: "The current playlist will be lost. Proceed with playlist generation?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let proceedAction = UIAlertAction(title: "Proceed", style: UIAlertActionStyle.destructive, handler: { a in self.generatePlaylist() })
        confirm.addAction(proceedAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        confirm.addAction(cancelAction)
        
        self.present(confirm, animated: true, completion: nil)
    }
    
    @IBAction func playPressed(_ sender: AnyObject) {
        self.engine.startPlaylist()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.engine.getPlaylistItemCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = engine.getPlaylistItemAtIndex(indexPath.item)
        cell.textLabel?.text = entry.name
        cell.detailTextLabel?.text = entry.artist
        cell.imageView?.image = entry.image
        return cell
    }

}

