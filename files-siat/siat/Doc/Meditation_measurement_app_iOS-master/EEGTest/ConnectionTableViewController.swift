//
//  ConnectionTableViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 05/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

protocol DetectNewDeviceDelegate {
    func addNewDevice (newDevice: String, RSSI: Int)
    func checkConnection (connected: Bool, errorMessage: String)
}

var central : Central?

//实例化DataSource和Delegate
class ConnectionTableViewController: UITableViewController, DetectNewDeviceDelegate {
    
    struct Device {
        var name: String
        var RSSI: Int
    }
    
    var listOfDetectedDevices = [Device]()//建立资料矩阵
    
    @IBOutlet var DeviceTable: UITableView!//关联控制项
    
    @IBAction func RefreshButton(sender: UIBarButtonItem) {
        central?.centralManager?.stopScan()
        central?.resetDetectedDevices()
        listOfDetectedDevices.removeAll()
        DeviceTable.reloadData()
        central?.centralManager?.scanForPeripheralsWithServices(nil, options: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        central = Central()
        central?.delegate = self//将UITableView的delegate指向自己
        
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func viewDidAppear(animated: Bool) {
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

 
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return listOfDetectedDevices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetectedDevice", forIndexPath: indexPath) as! UITableViewCell
    
        // Configure the cell...填充cell中标签的值
        cell.textLabel?.text = listOfDetectedDevices[indexPath.row].name;
        return cell
    }
    
    // Delegate method
    func addNewDevice(newDevice: String, RSSI: Int) {
        listOfDetectedDevices.append(Device(name: newDevice, RSSI: RSSI))
        DeviceTable.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)

        let selectedDevice = listOfDetectedDevices[indexPath.row]
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        
        // Connection prompt message
        let alertController = UIAlertController(title: "正在连接", message: "所选择设备 \(selectedDevice.name)", preferredStyle: .Alert)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        // Conduct connecting procedure
        central?.connecting(selectedDevice.name)
    }

    // delegate method
    func checkConnection (connected: Bool, errorMessage: String) {
        // Successful
        if connected {
            dismissViewControllerAnimated(true, completion: {() -> ()
                in
                self.performSegueWithIdentifier("ConnectedSegue", sender: nil)
            })
        }
            
        // Fail
        else {
            dismissViewControllerAnimated(true, completion: {() -> ()
                in
                let alertControllerFail = UIAlertController(title: "连接失败", message: "\(errorMessage)", preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "好的", style: .Default, handler: nil)
                alertControllerFail.addAction(defaultAction)
                self.presentViewController(alertControllerFail, animated: true, completion: nil)
            })
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
