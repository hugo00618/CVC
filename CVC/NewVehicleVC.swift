//
//  NewVehicleController.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-16.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation
import UIKit

let PICKER_TYPE_YEAR   = 0
let PICKER_TYPE_MAKE   = 1
let PICKER_TYPE_TIRE   = 2

let NEW_VEHICLE_SEGUE_ID_YEAR = "year"
let NEW_VEHICLE_SEGUE_ID_MAKE = "make"
let NEW_VEHICLE_SEGUE_ID_TIRE = "tire"

let NEW_VEHICLE_CONFIG_KEY = "newVehicleConfig"

class NewVehicleVC: UITableViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var button_save: UIBarButtonItem!
    @IBOutlet weak var label_yearDetail: UILabel!
    @IBOutlet weak var label_modelDetail: UILabel!
    @IBOutlet weak var textField_model: UITextField!
    @IBOutlet weak var label_makeDetail: UILabel!
    @IBOutlet weak var label_tireDetail: UILabel!
    @IBOutlet weak var label_gearRatioDetail: UILabel!
    @IBOutlet weak var tableCell_model: UITableViewCell!
    @IBOutlet weak var segCtrl_transType: UISegmentedControl!
    @IBOutlet weak var segCtrl_speedUnit: UISegmentedControl!
    
    var userDefaults:UserDefaults = UserDefaults.standard
    var vehicleConfig: VehicleConfig? = nil
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add gesture recognizer to the whole view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickView))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        // set textField_model delegate
        textField_model.delegate = self
        
        // add value changed event action to UISegmentedControl
        segCtrl_transType.addTarget(self, action: #selector(onChangeTransType), for: UIControlEvents.valueChanged)
        segCtrl_speedUnit.addTarget(self, action: #selector(onChangeSpeedUnit), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadVehicleConfig()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch(identifier) {
            case NEW_VEHICLE_SEGUE_ID_YEAR:
                let popoverCtrl = segue.destination.popoverPresentationController
                popoverCtrl?.delegate = self
                
                let destVC = (segue.destination as! UINavigationController).viewControllers.first as! PickerVC
                destVC.pickerType = PICKER_TYPE_YEAR
                break
            case NEW_VEHICLE_SEGUE_ID_MAKE:
                let popoverCtrl = segue.destination.popoverPresentationController
                popoverCtrl?.delegate = self
                
                let destVC = (segue.destination as! UINavigationController).viewControllers.first as! PickerVC
                destVC.pickerType = PICKER_TYPE_MAKE
                break
            case NEW_VEHICLE_SEGUE_ID_TIRE:
                let popoverCtrl = segue.destination.popoverPresentationController
                popoverCtrl?.delegate = self
                
                let destVC = (segue.destination as! UINavigationController).viewControllers.first as! PickerVC
                destVC.pickerType = PICKER_TYPE_TIRE
                break
            default:
                break
            }
        }
    }
    
    
    // MARK: UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if (cell.isHidden) {
            return 0;
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        switch(section) {
        case 0:
            switch(row) {
            case 2: // model
                label_modelDetail.isHidden = true
                textField_model.text = label_modelDetail.text
                textField_model.isHidden = false
                textField_model.becomeFirstResponder()
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    
    // MARK: Actions
    func onClickView(_ gestureRecognizer: UIGestureRecognizer) {
        if (!textField_model.bounds.contains(gestureRecognizer.location(in: textField_model))) {
            removeTextFieldFocus()
        }
    }
    @IBAction func onClickCancel(_ sender: AnyObject) {
        deleteNewVehicleConfig()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickSave(_ sender: AnyObject) {
        deleteNewVehicleConfig()
        
        // save to vehicle list
        var vehicles = userDefaults.object(forKey: VEHICLE_LIST_KEY) as! [Data]
        vehicles.append(NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!))
        userDefaults.set(vehicles, forKey: VEHICLE_LIST_KEY)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Delegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        DispatchQueue.main.async(execute: {
            self.reloadVehicleConfig()
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeTextFieldFocus()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        removeTextFieldFocus()
        return true
    }
    
    
    func removeTextFieldFocus() {
        textField_model.resignFirstResponder()
        textField_model.isHidden = true
        
        vehicleConfig?.model = textField_model.text!
        let encodedVehicleConfig = NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!)
        userDefaults.set(encodedVehicleConfig, forKey: NEW_VEHICLE_CONFIG_KEY)
        
        label_modelDetail.text = textField_model.text
        label_modelDetail.isHidden = false
    }
    func deleteNewVehicleConfig() {
        userDefaults.removeObject(forKey: NEW_VEHICLE_CONFIG_KEY)
    }
    
    func saveVehicleConfig() {
        let encodedVehicleConfig = NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!)
        userDefaults.set(encodedVehicleConfig, forKey: NEW_VEHICLE_CONFIG_KEY)
    }
    
    func onChangeTransType() {
        vehicleConfig?.automatic = segCtrl_transType.selectedSegmentIndex == 1
        saveVehicleConfig()
    }
    
    func onChangeSpeedUnit() {
        vehicleConfig?.kmph = segCtrl_speedUnit.selectedSegmentIndex == 0
        saveVehicleConfig()
    }
    
    func reloadVehicleConfig() {
        // get new vehicle config file
        let encodedVehicleConfig = userDefaults.object(forKey: NEW_VEHICLE_CONFIG_KEY) as? Data
        if (encodedVehicleConfig == nil) {
            vehicleConfig = VehicleConfig()
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: vehicleConfig!), forKey: NEW_VEHICLE_CONFIG_KEY)
        } else {
            vehicleConfig = NSKeyedUnarchiver.unarchiveObject(with: encodedVehicleConfig!) as? VehicleConfig
        }
        
        // update model cell visibility
        //        tableCell_model.hidden = vehicleConfig?.model == ""
        //        self.tableView.beginUpdates()
        //        self.tableView.reloadData()
        //        self.tableView.endUpdates()
        
        checkSaveAbility()
        
        // set details for table cells
        label_yearDetail.text = vehicleConfig!.year == 0 ? "" : String(vehicleConfig!.year)
        label_makeDetail.text = vehicleConfig!.make
        label_modelDetail.text = vehicleConfig!.model
        segCtrl_transType.selectedSegmentIndex = vehicleConfig!.automatic ? 1 : 0
        label_gearRatioDetail.text = vehicleConfig!.gearRatioProfile == nil ? "" : vehicleConfig?.gearRatioProfile!.name
        label_tireDetail.text = vehicleConfig!.tireWidth == 0 ? "" : (String(vehicleConfig!.tireWidth) + "/" + String(vehicleConfig!.tireProfile) + "R" + String(vehicleConfig!.tireDiameter))
        segCtrl_speedUnit.selectedSegmentIndex = vehicleConfig!.kmph ? 0 : 1
    }
    
    func checkSaveAbility() {
        button_save.isEnabled = ((vehicleConfig?.make != "" || vehicleConfig?.model != "") && vehicleConfig?.gearRatioProfile != nil && vehicleConfig?.tireWidth != 0)
    }
}
