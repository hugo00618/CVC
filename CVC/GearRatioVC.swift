//
//  GearRatioVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-26.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

let KEY_GEAR_RATIO_PRESETS = "gearRatioPresets"
let KEY_USER_DEFINED_GEAR_RATIO_PROFILES = "udgrProfiles"

let TABLE_CELL_REUSE_ID_GEAR_RATIO_PROFILE = "gearRatioProfileCell"
let TABLE_CELL_REUSE_ID_GEAR_RATIO_ADD_NEW_PROFILE = "gearRatioAddNewProfileCell"

class GearRatioVC: UITableViewController {
    
    var userDefaults:UserDefaults = UserDefaults.standard
    
    var vehicleConfig: VehicleConfig? = nil
    var encodedGrps: [String: [Data]]? = nil
    var udgrps = [GearRatioProfile]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "PRESETS"
        case 1:
            return "USER-DEFINED"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            let myGrps = encodedGrps![vehicleConfig!.make]
            return myGrps == nil ? 0 : myGrps!.count
        case 1:
            return udgrps.count + 1 // add new cell
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        var cell = self.tableView.dequeueReusableCell(withIdentifier: TABLE_CELL_REUSE_ID_GEAR_RATIO_PROFILE)!
        
        switch (section) {
        case 0:
            var myGrps = encodedGrps![vehicleConfig!.make]!
            let myGrp = NSKeyedUnarchiver.unarchiveObject(with: myGrps[row]) as! GearRatioProfile
            
            cell.textLabel?.text = myGrp.name
            cell.detailTextLabel?.text = "Gear Ratio; Final Drive Ratio: " + myGrp.getDetails()
            break;
        case 1:
            if (row == udgrps.count) { // add new cell
                cell = self.tableView.dequeueReusableCell(withIdentifier: TABLE_CELL_REUSE_ID_GEAR_RATIO_ADD_NEW_PROFILE)!
            } else {
                let myUdgrp = udgrps[row]
                
                cell.textLabel?.text = myUdgrp.name
                cell.detailTextLabel?.text = "Gear Ratio; Final Drive Ratio: " + myUdgrp.getDetails()
            }
            break;
        default:
            break;
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        
        if (section == 1 && row == udgrps.count) { // add new user-defined profile
            
        } else { // save profile to vehicle config
            switch (section) {
            case 0:
                var myGrps = encodedGrps![vehicleConfig!.make]!
                let myGrp = NSKeyedUnarchiver.unarchiveObject(with: myGrps[row]) as! GearRatioProfile
                vehicleConfig?.gearRatioProfile = myGrp
                break;
            case 1:
                let myUdgrp = udgrps[row]
                vehicleConfig?.gearRatioProfile = myUdgrp
                break;
            default:
                break;
            }
            
            // save vehicle config
            let encodedVehicleConfig = NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!)
            userDefaults.set(encodedVehicleConfig, forKey: NEW_VEHICLE_CONFIG_KEY)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setup() {
        // read vehicle config
        let encodedVehicleConfig = userDefaults.object(forKey: NEW_VEHICLE_CONFIG_KEY) as! Data
        vehicleConfig = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicleConfig) as! VehicleConfig
        
        // read preset
        encodedGrps = userDefaults.object(forKey: KEY_GEAR_RATIO_PRESETS) as! [String: [Data]]
        
        // read user config
        let encodedUdgrps = userDefaults.object(forKey: KEY_USER_DEFINED_GEAR_RATIO_PROFILES) as! Data
        udgrps = NSKeyedUnarchiver.unarchiveObject(with: encodedUdgrps) as! [GearRatioProfile]
    }
    
}

