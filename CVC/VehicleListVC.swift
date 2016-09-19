//
//  VehicleListTableViewController.swift
//  CVC
//
//  Created by Hugo Yu on 2015-11-27.
//  Copyright © 2015 Hugo Yu. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


let VEHICLE_LIST_KEY = "vehicleList"

class VehicleListVC: UITableViewController {
    
    var userDefaults:UserDefaults = UserDefaults.standard
    var encodedVehicles: [Data]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // show safty aleart
        let alertView = UIAlertView(title: "Operating hand-held devices while driving is illegal.\nPlease set up the app only when the vehicle is lawfully parked.", message: nil, delegate: nil, cancelButtonTitle: "Dismiss")
        alertView.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTable()
        
        let indexPath = IndexPath(row: 0, section: 0);
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return encodedVehicles == nil ? 0 : encodedVehicles!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        
        let myVehicle = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicles![(indexPath as NSIndexPath).row]) as! VehicleConfig
        
        cell.textLabel?.text = myVehicle.getName()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        refreshDetailView(indexPath)
    }
    
    @IBAction func onClickAdd(_ sender: AnyObject) {
        let detailVC = (self.splitViewController!.viewControllers[1] as! UINavigationController).topViewController as! VehicleDetailVC // get detail VC in split VC
        if(detailVC.isViewLoaded && detailVC.view.window != nil) { // if detail VC is visible
            detailVC.performSegue(withIdentifier: "showNewVehicleVC", sender: detailVC)
        }
    }
    
    func refreshTable() {
        // get new vehicle config file
        encodedVehicles = userDefaults.object(forKey: VEHICLE_LIST_KEY) as? [Data]
        if (encodedVehicles == nil) {
            encodedVehicles = [Data]()
            userDefaults.set(encodedVehicles, forKey: VEHICLE_LIST_KEY)
        }
        
        self.tableView.reloadData()
    }
    
    func refreshDetailView(_ indexPath: IndexPath) {
        var myVehicle: VehicleConfig? = nil
        if ((indexPath as NSIndexPath).row < encodedVehicles?.count) {
            myVehicle = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicles![(indexPath as NSIndexPath).row]) as! VehicleConfig
        }
        ((self.splitViewController!.viewControllers[1] as! UINavigationController).topViewController as! VehicleDetailVC).refreshView(myVehicle)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
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
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
