//
//  VehicleDetailVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-27.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class VehicleDetailVC: UITableViewController {
    
    @IBOutlet weak var label_vehicleName: UILabel!
    @IBOutlet weak var image_vehicleMake: UIImageView!
    
    var vehicleConfig: VehicleConfig? = nil
    
    // MARK: UIViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get master VC in split VC
        let masterVC = (self.splitViewController!.viewControllers[0] as! UINavigationController).topViewController as! VehicleListVC
        
        // refrsh master table content
        masterVC.refreshTable()
        
        // display first cell's info if available
        let myIndexPath = IndexPath(row: 0, section: 0)
        masterVC.tableView(masterVC.tableView, didSelectRowAt: myIndexPath)
    }
    
    func refreshView(_ vehicleConfig: VehicleConfig?) {
        self.vehicleConfig = vehicleConfig
        
        if (vehicleConfig == nil) {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            label_vehicleName.text = ""
            image_vehicleMake.image = nil
        } else {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            label_vehicleName.text = vehicleConfig!.getName()
            
            let vehicleMakeLogo = UIImage(named: vehicleConfig!.make+"_logo.png")
            if (vehicleMakeLogo == nil) {
                
            } else {
                image_vehicleMake.image = vehicleMakeLogo
                
            }
        }
    }
    
}
