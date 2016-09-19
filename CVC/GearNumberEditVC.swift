//
//  GearNumberEditVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-09-05.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

protocol GearNumberEditDelegate: class {
    func onClickGearNumberEditDelete()
    func saveGearNumberEditData(_ gearNumber: Int, gearRatio: Double, finalDriveRatio: Double)
}

class GearNumberEditVC: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var barButton_delete: UIBarButtonItem!
    @IBOutlet weak var barButton_save: UIBarButtonItem!
    @IBOutlet weak var label_gearRatio: UILabel!
    @IBOutlet weak var textField_gearRatio: UITextField!
    @IBOutlet weak var label_finalDriveRatio: UILabel!
    @IBOutlet weak var textField_finalDriveRatio: UITextField!
    
    var labels: [UILabel] = []
    var textFields: [UITextField] = []
    
    var gearNumber = 0
    var initGearRatio = Double()
    var initFinalDriveRatio = Double()
    
    var delegate: GearNumberEditDelegate?
    
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up label and textfield array
        labels = [label_gearRatio, label_finalDriveRatio]
        textFields = [textField_gearRatio, textField_finalDriveRatio]
        
        // init navigation titile
        self.navigationItem.title = "Gear " + String(gearNumber)
        
        // init labels
        label_gearRatio.text = initGearRatio == -1 ? GEAR_RATIO_INFO_NA : String(initGearRatio)
        label_finalDriveRatio.text = initFinalDriveRatio == -1 ? GEAR_RATIO_INFO_NA : String(initFinalDriveRatio)
        
        // add gesture recognizer to the whole view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickView))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        // set textField_model delegate
        textField_gearRatio.delegate = self
        textField_finalDriveRatio.delegate = self
        
        checkSaveAbility()
    }
    
    
    // MARK: UITableViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        switch(section) {
        case 0:
            switch(row) {
            case 0: // gear ratio
                textField_gearRatio.becomeFirstResponder()
                break
            case 1: // final drive ratio
                textField_finalDriveRatio.becomeFirstResponder()
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
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                if (textField.isFirstResponder && !textField.bounds.contains(gestureRecognizer.location(in: textField))) {
                    textField.resignFirstResponder()
                    break
                }
            }
        }
    }
    
    @IBAction func onClickDelete(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {
            self.delegate?.onClickGearNumberEditDelete()
        })
    }
    
    @IBAction func onClickSave(_ sender: AnyObject) {
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                textField.resignFirstResponder()
                break
            }
        }
        
        self.dismiss(animated: true, completion: {
            let myGearRatio = Double(self.label_gearRatio.text!)!
            let myFinalDriveRatio = Double(self.label_finalDriveRatio.text!)!
            
            self.delegate?.saveGearNumberEditData(self.gearNumber, gearRatio: myGearRatio, finalDriveRatio: myFinalDriveRatio)
        })
    }
    
    // MARK: Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let label = getTextFieldCorrespondingLabel(textField)
        
        label.isHidden = true
        textField.text = label.text == GEAR_RATIO_INFO_NA ? "" : label.text
        textField.isHidden = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let index = textFields.index(of: textField)!
        if (index < textFields.count - 1) {
            textFields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let label = getTextFieldCorrespondingLabel(textField)
        
        textField.isHidden = true
        
        label.text = textField.text
        label.isHidden = false
        
        checkSaveAbility()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        getTextFieldCorrespondingLabel(textField).text = newString
        checkSaveAbility()
        
        return true
    }
    
    
    // Other helpers
    func getTextFieldCorrespondingLabel(_ textField: UITextField) -> UILabel {
        return labels[(textFields.index(of: textField))!]
    }
    
    func checkSaveAbility() {
        if (Double(label_gearRatio.text!) != nil && Double(label_finalDriveRatio.text!) != nil) {
            barButton_save.isEnabled = true
        } else {
            barButton_save.isEnabled = false
        }
    }
}
