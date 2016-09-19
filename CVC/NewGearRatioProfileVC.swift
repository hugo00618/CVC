//
//  NewGearRatioProfileVC.swift
//  CVC
//
//  Created by Hugo Yu on 2016-09-04.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

let ID_VC_GEAR_NUMBER_EDIT_NAV = "GearNumberEditNav"

let GEAR_PATH_OVERLAP_HORIZONTAL: CGFloat = 6
let GEAR_PATH_OVERLAP_VERTICAL: CGFloat = 5
let GEAR_PATH_WIDTH: CGFloat = 132 - GEAR_PATH_OVERLAP_HORIZONTAL
let GEAR_PATH_HEIGHT: CGFloat = 91 - GEAR_PATH_OVERLAP_VERTICAL
let GEAR_NUMBER_WIDTH: CGFloat = 96
let GEAR_NUMBER_HEIGHT: CGFloat = 38
let GEAR_LABEL_PATH_SPACING: CGFloat = 10

let DEFAULT_GEAR_NUM = 5
let MIN_GEAR_NUM = 4
let MAX_GEAR_NUM = 10

struct Gear {
    var path: UIImageView?
    var number: GearNumberView
}

class NewGearRatioProfileVC: UITableViewController, UITextFieldDelegate, GearNumberEditDelegate {
    @IBOutlet weak var barButton_save: UIBarButtonItem!
    @IBOutlet weak var label_profileName: UILabel!
    @IBOutlet weak var textField_profileName: UITextField!
    @IBOutlet weak var view_container: UIView!
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var button_addGear: UIButton!
    
    var upperGearPathImage: UIImage!
    var lowerGearPathImage: UIImage!
    
    var gears = [Gear?](repeating: nil, count: MAX_GEAR_NUM)
    var currentMaxGearIndex = -1
    
    var myGearRatioProfile = GearRatioProfile()
    
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add gesture recognizer to the whole view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickView))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        // set textField_model delegate
        textField_profileName.delegate = self
        
        initGearRatioEditUI()
    }
    
    
    // MARK: UITableViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        switch(section) {
        case 0:
            switch(row) {
            case 0: // name
                textField_profileName.becomeFirstResponder()
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
        if (!textField_profileName.bounds.contains(gestureRecognizer.location(in: textField_profileName))) {
            textField_profileName.resignFirstResponder()
        }
    }
    @IBAction func onClickCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickSave(_ sender: AnyObject) {
        let myProfileName = label_profileName.text!
        var myGearRatios = [Double]()
        var myFinalDriveRatios = [Double]()
        var myFdrMaxGears = [Int]()
        
        var currFdr = gears[0]!.number.finalDriveRatio
        myFinalDriveRatios.append(currFdr)
        for (index, gear) in gears.enumerated() {
            let gearNumberView = gear!.number
            if !gearNumberView.isHidden {
                myGearRatios.append(gearNumberView.gearRatio)
                
                let myFinalDriveRatio = gearNumberView.finalDriveRatio
                if myFinalDriveRatio != currFdr {
                    myFinalDriveRatios.append(myFinalDriveRatio)
                    
                    myFdrMaxGears.append(index - 1)
                    
                    currFdr = myFinalDriveRatio
                }
            } else {
                myFdrMaxGears.append(index - 1)
                break
            }
        }
        
         let gearRatioProfile = GearRatioProfile(name: myProfileName, gearRatios: myGearRatios, finalDriveRatios: myFinalDriveRatios, fdrMaxGears: myFdrMaxGears)
        
        print(gearRatioProfile.gearRatios)
        print(gearRatioProfile.finalDriveRatios)
        print(gearRatioProfile.fdrMaxGears)
    }
    
    @IBAction func onClickAddGear(_ sender: AnyObject) {
        addGear()
        repositionGearProfileContentView()
    }
    
    func onClickGearNumber(_ gestureRecognizer: UIGestureRecognizer) {
        let sender = gestureRecognizer.view as! GearNumberView
        let gearNumber = Int(sender.label_gearNum.text!)!
        
        let popoverNavVC = self.storyboard!.instantiateViewController(withIdentifier: ID_VC_GEAR_NUMBER_EDIT_NAV) as! UINavigationController
        popoverNavVC.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverNavVC.preferredContentSize = CGSize(width: 376, height: 220)
        let popover = popoverNavVC.popoverPresentationController!
        popover.sourceView = sender
        popover.permittedArrowDirections = gearNumber % 2 == 0 ? UIPopoverArrowDirection.down : [UIPopoverArrowDirection.left, UIPopoverArrowDirection.right]
        popover.sourceRect = sender.bounds
        
        let gearNumberEditVC = popoverNavVC.viewControllers.first as! GearNumberEditVC
        
        // set delete button ability
        if (gearNumber == currentMaxGearIndex + 1 && currentMaxGearIndex >= MIN_GEAR_NUM) {
            gearNumberEditVC.barButton_delete.isEnabled = true
        }
        
        gearNumberEditVC.gearNumber = gearNumber
        gearNumberEditVC.initGearRatio = sender.gearRatio
        gearNumberEditVC.initFinalDriveRatio = sender.finalDriveRatio
        
        gearNumberEditVC.delegate = self
        
        self.present(popoverNavVC, animated: true, completion: nil)
    }
    
    
    // MARK: Delegate
    func onClickGearNumberEditDelete() {
        removeGear()
        repositionGearProfileContentView()
    }
    func saveGearNumberEditData(_ gearNumber: Int, gearRatio: Double, finalDriveRatio: Double) {
        let myGearNumberView = gears[gearNumber - 1]!.number
        
        myGearNumberView.gearRatio = gearRatio
        myGearNumberView.finalDriveRatio = finalDriveRatio
        
        myGearNumberView.updateGearRatioLabel()
        
        // sync final drive ratio with all following gears
        for gear in gears {
            let followingGearNumberView = gear!.number
            followingGearNumberView.finalDriveRatio = finalDriveRatio
            followingGearNumberView.updateGearRatioLabel()
        }
        
        checkSaveAbility()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        label_profileName.isHidden = true
        textField_profileName.text = label_profileName.text
        textField_profileName.isHidden = false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        removeTextFieldFocus()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField_profileName.isHidden = true
        
        myGearRatioProfile.name = textField_profileName.text!
        
        label_profileName.text = textField_profileName.text
        label_profileName.isHidden = false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        label_profileName.text = newString
        checkSaveAbility()
        
        return true
    }
    
    
    func initGearRatioEditUI() {
        // disable auto layout
        view_content.translatesAutoresizingMaskIntoConstraints = true
        button_addGear.translatesAutoresizingMaskIntoConstraints = true
        
        // load gear path images
        upperGearPathImage = UIImage(named: "gearPath")
        lowerGearPathImage = UIImage(cgImage: upperGearPathImage.cgImage!, scale: upperGearPathImage.scale, orientation: UIImageOrientation.downMirrored)
        
        initGear()
        
        for _ in 1...DEFAULT_GEAR_NUM {
            addGear()
        }
        
        // resize & center container
        repositionGearProfileContentView()
    }
    
    func initGear() {
        var gearNumX: CGFloat = 0
        var gearNumY: CGFloat = 0
        var gearPathX: CGFloat = 0
        var gearPathY: CGFloat = 0
        
        gearPathX = GEAR_NUMBER_WIDTH * 1 / 2 - GEAR_PATH_OVERLAP_HORIZONTAL * 1 / 2
        gearPathY = GEAR_NUMBER_HEIGHT + GEAR_LABEL_PATH_SPACING
        
        for i in stride(from: 0, to: MAX_GEAR_NUM, by: 2) {
            // upper gear number
            let myGearNumber = GearNumberView()
            
            myGearNumber.frame.origin.x = gearNumX
            myGearNumber.frame.origin.y = gearNumY
            myGearNumber.isHidden = true
            
            myGearNumber.label_gearNum.text = String(i+1)
            myGearNumber.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewGearRatioProfileVC.onClickGearNumber)))
            
            view_content.addSubview(myGearNumber)
            
            gearNumX += GEAR_PATH_WIDTH
            
            // upper gear path
            var myGearPath: UIImageView! = nil
            if i != 2 {
                myGearPath = UIImageView(image: upperGearPathImage)
                
                myGearPath.frame.origin.x = gearPathX
                myGearPath.frame.origin.y = gearPathY
                myGearPath.isHidden = true
                
                view_content.addSubview(myGearPath)
                
                gearPathX += GEAR_PATH_WIDTH
            }
            
            gears[i] = Gear(path: myGearPath, number: myGearNumber)
        }
        
        gearPathX = GEAR_NUMBER_WIDTH * 1 / 2 - GEAR_PATH_OVERLAP_HORIZONTAL * 1 / 2
        gearPathY += GEAR_PATH_HEIGHT
        gearNumX = 0
        gearNumY = gearPathY + GEAR_PATH_HEIGHT + GEAR_PATH_OVERLAP_VERTICAL + GEAR_LABEL_PATH_SPACING
        
        for i in stride(from: 1, to: MAX_GEAR_NUM, by: 2) {
            // lower gear number
            let myGearNumber = GearNumberView()
            
            myGearNumber.frame.origin.x = gearNumX
            myGearNumber.frame.origin.y = gearNumY
            myGearNumber.isHidden = true
            
            myGearNumber.label_gearNum.text = String(i+1)
            myGearNumber.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NewGearRatioProfileVC.onClickGearNumber)))
            
            view_content.addSubview(myGearNumber)
            
            gearNumX += GEAR_PATH_WIDTH
            
            // lower gear path
            var myGearPath: UIImageView! = nil
            if i != 3 {
                myGearPath = UIImageView(image: lowerGearPathImage)
                
                myGearPath.frame.origin.x = gearPathX
                myGearPath.frame.origin.y = gearPathY
                myGearPath.isHidden = true
                
                view_content.addSubview(myGearPath)
                
                gearPathX += GEAR_PATH_WIDTH
            }
            
            gears[i] = Gear(path: myGearPath, number: myGearNumber)
        }
    }
    
    func addGear() {
        currentMaxGearIndex += 1
        
        let myGear = gears[currentMaxGearIndex]!
        if let myGearPath = myGear.path {
            myGearPath.isHidden = false
            myGearPath.alpha = 1
        }
        myGear.number.isHidden = false
        
        if currentMaxGearIndex + 1 < MAX_GEAR_NUM {
            let nextGear = gears[currentMaxGearIndex + 1]!
            if let nextGearPath = nextGear.path {
                nextGearPath.isHidden = false
                nextGearPath.alpha = 0.5
            }
            button_addGear.center = nextGear.number.center
        } else {
            button_addGear.isHidden = true
        }
    }
    
    func removeGear() {
        let myGear = gears[currentMaxGearIndex]!
        if let myGearPath = myGear.path {
            myGearPath.alpha = 0.5
        }
        myGear.number.isHidden = true
        button_addGear.isHidden = false
        button_addGear.center = myGear.number.center
        
        if currentMaxGearIndex + 1 < MAX_GEAR_NUM {
            let nextGear = gears[currentMaxGearIndex + 1]!
            if let nextGearPath = nextGear.path {
                nextGearPath.isHidden = true
            }
        }
        
        currentMaxGearIndex -= 1
    }
    
    func repositionGearProfileContentView() {
        resizeToFitSubviews(view_content)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view_content.center = self.view_container.center
            }, completion: nil)
    }
    
    func resizeToFitSubviews(_ view: UIView) {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        for subView in view.subviews {
            if !subView.isHidden {
                let myWidth = subView.frame.origin.x + subView.frame.size.width
                let myHeight = subView.frame.origin.y + subView.frame.size.height
                
                width = max(width, myWidth)
                height = max(height, myHeight)
            }
        }
        
        view.frame.size.width = width
        view.frame.size.height = height
    }
    
    func checkSaveAbility() {
        if (label_profileName.text == "") {
            barButton_save.isEnabled = false
            return
        }
        
        for myGear in gears {
            let myGearNumberView = myGear!.number
            if (myGearNumberView.isHidden) { // all visible gears checked, good to save
                barButton_save.isEnabled = true
                break
            }
            if (myGearNumberView.gearRatio == -1 || myGearNumberView.finalDriveRatio == -1) {
                barButton_save.isEnabled = false
                break
            }
        }
    }
}
