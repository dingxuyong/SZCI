//
//  SettingsTableViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 07/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 7
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // check battery
        if indexPath.section == 0 && indexPath.row == 0 {
            let battery = central?.battery
            
            let alertController = UIAlertController(title: "剩余电池电量", message: "\(battery!)%", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            }
        
        // about us
        if indexPath.section == 4 && indexPath.row == 0 {
            let alertController = UIAlertController(title: "关于我们", message: "衡思健康（HyperNeuro）创始于一班来自英国帝国理工的团队，我们一直致力于大数据技术和生命科学的研究，在许多科技领域上的研究都处于世界的前列，并在海内外开展许多相关的研究项目，希望能把最先进的科学技术融入到个性化健康中。", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // acknowledgement
        if indexPath.section == 5 && indexPath.row == 0 {
            let alertController = UIAlertController(title: "致谢", message: " \"Canon in D Major\" Kevin MacLeod (incompetech.com) Licensed under Creative Commons: By Attribution 3.0 http://creativecommons.org/licenses/by/3.0/ ", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // disconnect
        if indexPath.section == 6 && indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            central?.disconnect()
        }
        
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
