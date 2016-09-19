//
//  GearRatioProfile.swift
//  CVC
//
//  Created by Hugo Yu on 2016-03-25.
//  Copyright © 2016 Hugo Yu. All rights reserved.
//

import Foundation

class GearRatioProfile : NSObject, NSCoding {
    var name: String
    var gearRatios: [Double]
    var finalDriveRatios: [Double]
    var fdrMaxGears: [Int]
    
    init(name: String, gearRatios: [Double], finalDriveRatios: [Double], fdrMaxGears: [Int]) {
        self.name = name
        self.gearRatios = gearRatios
        self.finalDriveRatios = finalDriveRatios
        self.fdrMaxGears = fdrMaxGears
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        gearRatios = aDecoder.decodeObject(forKey: "gearRatios") as! [Double]
        finalDriveRatios = aDecoder.decodeObject(forKey: "finalDriveRatios") as! [Double]
        fdrMaxGears = aDecoder.decodeObject(forKey: "fdrMaxGears") as! [Int]
    }
    
    convenience override init() {
        self.init(name: "", gearRatios: [], finalDriveRatios: [], fdrMaxGears: [])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(gearRatios, forKey: "gearRatios")
        aCoder.encode(finalDriveRatios, forKey: "finalDriveRatios")
        aCoder.encode(fdrMaxGears, forKey: "fdrMaxGears")
    }
    
    func getDetails() -> String {
        var currGearIdx = 0, currFgrIdx = 0
        var profileDetails = ""
        for gearRatio in gearRatios {
            profileDetails += String(gearRatio)
            if (currGearIdx == fdrMaxGears[currFgrIdx]) {
                profileDetails += "; " + String(finalDriveRatios[currFgrIdx]) + "    "
                currFgrIdx += 1
            } else {
                profileDetails += ", "
            }
            currGearIdx += 1
        }
        return profileDetails
    }
    
}
