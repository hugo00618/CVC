//
//  GearNumberView.swift
//  CVC
//
//  Created by Hugo Yu on 2016-09-04.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import UIKit

let GEAR_RATIO_INFO_NA = "N/A"

class GearNumberView: UIView {
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var label_gearNum: UILabel!
    @IBOutlet weak var label_gearRatioInfo: UILabel!
    
    var gearRatio: Double = -1
    var finalDriveRatio: Double = -1

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("GearNumberView", owner: self, options: nil)
        self.bounds = self.view.bounds
        
        initView()
        
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("GearNumberView", owner: self, options: nil)
        
        initView()
        
        self.addSubview(view)
    }
    
    func initView() {
        updateGearRatioLabel()
    }
    
    func updateGearRatioLabel() {
        label_gearRatioInfo.text = (gearRatio == -1 ? GEAR_RATIO_INFO_NA : String(gearRatio)) + "\n" + (finalDriveRatio == -1 ? GEAR_RATIO_INFO_NA : String(finalDriveRatio))
    }

}
