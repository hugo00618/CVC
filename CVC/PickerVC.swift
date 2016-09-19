//
//  YearPickerController.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-16.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation
import UIKit

let FROM_YEAR = 1990

let MAKE_OTHER_TEXT = "Other"

let TIRE_WIDTH_FROM    = 145
let TIRE_WIDTH_TO      = 355
let TIRE_PROFILE_FROM  = 25
let TIRE_PROFILE_TO    = 85
let TIRE_DIAMETER_FROM = 12
let TIRE_DIAMETER_TO   = 30

let TIRE_WIDTH_DEFAULT    = 215
let TIRE_PROFILE_DEFAULT  = 55
let TIRE_DIAMETER_DEFAULT = 17

class PickerVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker_master: UIPickerView!
    
    var pickerType = -1
    
    var userDefaults:UserDefaults = UserDefaults.standard
    var vehicleConfig:VehicleConfig?
    
    var index0 = 0, index1 = 0, index2 = 0
    
    // Year
    var years = [Int]()
    
    // Make
    var makes = [String]()
    
    // Tire
    var widths = [Int](), profiles = [Int](), diameters = [Int]()
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init picker
        picker_master.delegate = self
        picker_master.dataSource = self
        
        // read vehicle config file
        let encodedVehicleConfig = userDefaults.object(forKey: NEW_VEHICLE_CONFIG_KEY) as! Data
        vehicleConfig = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicleConfig) as? VehicleConfig
        
        switch(pickerType) {
        case PICKER_TYPE_YEAR:
            self.navigationItem.title = "Vehicle Year"
            
            // lazy init
            if (years.isEmpty) {
                initYears()
            }
            
            // pre-select the saved year or the second last year if empty
            index0 = vehicleConfig!.year == 0 ? years.count - 2 : (vehicleConfig!.year - FROM_YEAR)
            picker_master.selectRow(index0, inComponent: 0, animated: true)
            
            break;
        case PICKER_TYPE_MAKE:
            self.navigationItem.title = "Vehicle Make"
            
            // lazy init
            if (makes.isEmpty) {
                initCarMakes()
            }
            
            // pre-select the saved make or the first make if empty
            index0 = vehicleConfig!.make == "" ? 1 : makes.index(of: vehicleConfig!.make)!
            picker_master.selectRow(index0, inComponent: 0, animated: true)
            
            break;
        case PICKER_TYPE_TIRE:
            self.navigationItem.title = "Tire Size"
            
            // lazy init
            if (widths.isEmpty) {
                initTire()
            }
            
            // pre-select the save tire data or default data if empty
            let thisWidthIndex:Int? = widths.index(of: vehicleConfig!.tireWidth)
            index0 = thisWidthIndex == nil ? widths.index(of: TIRE_WIDTH_DEFAULT)! : thisWidthIndex!
            let thisProfileIndex:Int? = profiles.index(of: vehicleConfig!.tireProfile)
            index1 = thisProfileIndex == nil ? profiles.index(of: TIRE_PROFILE_DEFAULT)! : thisProfileIndex!
            let thisDiameterIndex:Int? = diameters.index(of: vehicleConfig!.tireDiameter)
            index2 = thisDiameterIndex == nil ? diameters.index(of: TIRE_DIAMETER_DEFAULT)! : thisDiameterIndex!
            picker_master.selectRow(index0, inComponent: 0, animated: true)
            picker_master.selectRow(index1, inComponent: 1, animated: true)
            picker_master.selectRow(index2, inComponent: 2, animated: true)
            
            break;
        default:
            break;
        }
    }
    
    // MARK: Action
    @IBAction func onClickDone(_ sender: AnyObject) {
        savePickerValue()
        
        let navigationCtrl = self.navigationController!
        
        navigationCtrl.dismiss(animated: true, completion: nil)
        navigationCtrl.popoverPresentationController!.delegate!.popoverPresentationControllerDidDismissPopover!(navigationCtrl.popoverPresentationController!)
    }
    @IBAction func onClickCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePickerValue() {
        switch(pickerType) {
        case PICKER_TYPE_YEAR:
            index0 = picker_master.selectedRow(inComponent: 0)
            vehicleConfig?.year = years[index0]
            saveVehicleConfig()
            break;
        case PICKER_TYPE_MAKE:
            let newIdx = picker_master.selectedRow(inComponent: 0)
            let myMake = makes[newIdx]
            vehicleConfig?.make = myMake
            updateSCF(myMake)
            saveVehicleConfig()
            break;
        case PICKER_TYPE_TIRE:
            index0 = picker_master.selectedRow(inComponent: 0)
            index1 = picker_master.selectedRow(inComponent: 1)
            index2 = picker_master.selectedRow(inComponent: 2)
            
            vehicleConfig?.tireWidth = widths[index0]
            vehicleConfig?.tireProfile = profiles[index1]
            vehicleConfig?.tireDiameter = diameters[index2]
            
            saveVehicleConfig()
            break;
        default:
            break;
        }
    }
    
    func saveVehicleConfig() {
        let encodedVehicleConfig = NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!)
        userDefaults.set(encodedVehicleConfig, forKey: NEW_VEHICLE_CONFIG_KEY)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch(pickerType) {
        case PICKER_TYPE_YEAR, PICKER_TYPE_MAKE:
            return 1
        case PICKER_TYPE_TIRE:
            return 3
        default:
            return -1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerType) {
        case PICKER_TYPE_YEAR:
            return years.count
        case PICKER_TYPE_MAKE:
            return makes.count
        case PICKER_TYPE_TIRE:
            switch (component) {
            case 0:
                return widths.count
            case 1:
                return profiles.count
            case 2:
                return diameters.count
            default:
                return -1
            }
        default:
            return -1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch(pickerType) {
        case PICKER_TYPE_YEAR:
            return NSAttributedString(string: String(years[row]))
        case PICKER_TYPE_MAKE:
            return NSAttributedString(string: makes[row])
        case PICKER_TYPE_TIRE:
            switch (component) {
            case 0:
                return NSAttributedString(string: String(widths[row]))
            case 1:
                return NSAttributedString(string: String(profiles[row]))
            case 2:
                return NSAttributedString(string: "R" + String(diameters[row]))
            default:
                return nil
            }
        default:
            return nil
        }
        
    }
    
    func updateSCF(_ make: String) {
        switch(make) {
        case "Volkswagen":
            vehicleConfig?.speedoCalibFac = 1.07
            break
        default:
            vehicleConfig?.speedoCalibFac = 1.0
            break
        }
    }
    
    func initYears() {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let toYear:Int = Int(df.string(from: Date()))! + 1
        for i in FROM_YEAR...toYear {
            years.append(i)
        }
    }
    
    func initCarMakes() {
        makes = [
            MAKE_OTHER_TEXT,
            "Acura",
            "Audi",
            "BMW",
            "Buick",
            "Cadillac",
            "Chevrolet",
            "Chrysler",
            "Citroen",
            "Dodge",
            "Fiat",
            "Ford",
            "GMC",
            "Honda",
            "Hummer",
            "Hyundai",
            "Infiniti",
            "Jaguar",
            "Jeep",
            "Kia",
            "Land Rover",
            "Lexus",
            "Lincoln",
            "Mazda",
            "Mercedes-Benz",
            "Mercury",
            "MINI",
            "Mitsubishi",
            "Nissan",
            "Opel",
            "Peugeot",
            "Pontiac",
            "RAM",
            "Renault",
            "Saab",
            "Saturn",
            "SEAT",
            "Skoda",
            "smart",
            "Subaru",
            "Suzuki",
            "Toyota",
            "Volkswagen",
            "Volvo"]
    }
    
    func initTire() {
        for i in stride(from: TIRE_WIDTH_FROM, through: TIRE_WIDTH_TO, by: 5) {
            widths.append(i)
        }
        for i in stride(from: TIRE_PROFILE_FROM, through: TIRE_PROFILE_TO, by: 5) {
            profiles.append(i)
        }
        for i in TIRE_DIAMETER_FROM ... TIRE_DIAMETER_TO {
            diameters.append(i)
        }
    }
    
}
