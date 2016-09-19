//
//  TextFieldVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-26.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

class TextFieldVC: UITableViewController, UITextFieldDelegate{
    @IBOutlet weak var textField_master: UITextField!
    
    var userDefaults:UserDefaults = UserDefaults.standard
    var vehicleConfig: VehicleConfig? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField_master.delegate = self
        
        // read vehicle config file
        let encodedVehicleConfig = userDefaults.object(forKey: NEW_VEHICLE_CONFIG_KEY) as! Data
        vehicleConfig = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicleConfig) as? VehicleConfig
        
        textField_master.text = vehicleConfig?.model
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField_master.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save vehicle model
        vehicleConfig?.model = textField_master.text!
        let encodedVehicleConfig = NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!)
        userDefaults.set(encodedVehicleConfig, forKey: NEW_VEHICLE_CONFIG_KEY)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.navigationController?.popViewController(animated: true)
        return true
    }
}
