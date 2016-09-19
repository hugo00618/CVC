//
//  AdvancedSettingsController.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-24.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class AdvancedSettingsVC: UITableViewController {
    
    @IBOutlet weak var label_speedoCalibFacDetail: UILabel!
    
    var userDefaults:UserDefaults = UserDefaults.standard
    var vehicleConfig: VehicleConfig? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Advanced"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let encodedVehicleConfig = userDefaults.object(forKey: NEW_VEHICLE_CONFIG_KEY) as! Data
        vehicleConfig = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicleConfig) as? VehicleConfig
        
        label_speedoCalibFacDetail.text = String(vehicleConfig!.speedoCalibFac)
    }
}
