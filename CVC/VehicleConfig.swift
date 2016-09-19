//
//  VehicleConfig.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-25.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation

class VehicleConfig: NSObject, NSCoding {
    var make = "", model = ""
    var year = 0, tireWidth = 0, tireProfile = 0, tireDiameter = 0
    var automatic = false, kmph = true
    var gearRatioProfile: GearRatioProfile? = nil;
    var speedoCalibFac = 1.0
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        year = aDecoder.decodeObject(forKey: "year") as! Int
        make = aDecoder.decodeObject(forKey: "make") as! String
        model = aDecoder.decodeObject(forKey: "model") as! String
        automatic = aDecoder.decodeObject(forKey: "transType") as! Bool
        gearRatioProfile = aDecoder.decodeObject(forKey: "grp") as? GearRatioProfile
        tireWidth = aDecoder.decodeObject(forKey: "tireWidth") as! Int
        tireProfile = aDecoder.decodeObject(forKey: "tireProfile") as! Int
        tireDiameter = aDecoder.decodeObject(forKey: "tireDiameter") as! Int
        kmph = aDecoder.decodeObject(forKey: "speedUnit") as! Bool
        speedoCalibFac = aDecoder.decodeObject(forKey: "scf") as! Double
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(year, forKey: "year")
        aCoder.encode(make, forKey: "make")
        aCoder.encode(model, forKey: "model")
        aCoder.encode(automatic, forKey: "transType")
        aCoder.encode(gearRatioProfile, forKey: "grp")
        aCoder.encode(tireWidth, forKey: "tireWidth")
        aCoder.encode(tireProfile, forKey: "tireProfile")
        aCoder.encode(tireDiameter, forKey: "tireDiameter")
        aCoder.encode(kmph, forKey: "speedUnit")
        aCoder.encode(speedoCalibFac, forKey: "scf")
    }
    
    func getName() -> String {
        var name = ""
        if (year != 0) {
            name += String(year) + " "
        }
        if (make != MAKE_OTHER_TEXT) {
            name += make + " "
        }
        if (model != "") {
            name += model
        }
        return name
    }
    
}
