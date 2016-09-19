//
//  GaugeViewController.swift
//  CVC
//
//  Created by Hugo Yu on 2015-11-27.
//  Copyright © 2015 Hugo Yu. All rights reserved.
//

import UIKit
import QuartzCore
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


let SPEED_CALIBRATION_FACTOR = 1.07
let TIRE_WIDTH: Double = 235
let TIRE_PROFILE: Double = 40
let RIM_SIZE: Double = 18
let GEARBOX_AUTOMATIC = true // inertial gear prediction
let GEAR_RATIO_1 = 3.46
let GEAR_RATIO_2 = 2.05
let GEAR_RATIO_3 = 1.3
let GEAR_RATIO_4 = 0.9
let GEAR_RATIO_5 = 0.91
let GEAR_RATIO_6 = 0.76
let GEAR_RATIO_FINAL_1 = 4.12
let GEAR_RATIO_FINAL_2 = 3.04
let GEAR_RATIOS = [GEAR_RATIO_1, GEAR_RATIO_2, GEAR_RATIO_3, GEAR_RATIO_4, GEAR_RATIO_5, GEAR_RATIO_6]

var WHEEL_CIRCUM_KM = 0.0

let PID_ALL = "all"

// animation
let NEEDLE_ON_DURATION = 0.3
let GAUGE_SWEEP_DURATION = 0.8 // one-way
let RPM_INIT_DURATION = 0.3
let RPM_GAUGE_UPDATE_DURATION = 0.15
let SPEED_GAUGE_UPDATE_DURATION = 0.5
let GAUGE_OFF_DURATION = 0.5

let KEY_SWEEP = 1
let KEY_SWEEP_BACK = 2

class GaugeVC: UIViewController, CAAnimationDelegate {
    
    @IBOutlet weak var img_frameLeft: UIImageView!
    @IBOutlet weak var img_pivotLeft: UIImageView!
    @IBOutlet weak var img_tachoScale: UIImageView!
    @IBOutlet weak var img_tachoRead: UIImageView!
    @IBOutlet weak var img_tachoUnit: UIImageView!
    @IBOutlet weak var img_needleLeft: UIImageView!
    @IBOutlet weak var img_smallGaugesFrame: UIImageView!
    @IBOutlet weak var img_frameRight: UIImageView!
    @IBOutlet weak var img_pivotRight: UIImageView!
    @IBOutlet weak var img_speedScale: UIImageView!
    @IBOutlet weak var img_speedRead: UIImageView!
    @IBOutlet weak var img_speedUnit: UIImageView!
    @IBOutlet weak var img_needleRight: UIImageView!
    
    @IBOutlet weak var label_speed: UILabel!
    @IBOutlet weak var label_gear: UILabel!
    
    var lastUpdated = Double(-1)
    var curRPM = Double(0)
    var curSpeed = Double(0)
    var curGear: Int = 1
    
    var blockDict = [String: Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize WHEEL_CIRCUM_KM
        WHEEL_CIRCUM_KM = (TIRE_WIDTH * TIRE_PROFILE / 100.0 * 2.0 + RIM_SIZE * 25.4)
        WHEEL_CIRCUM_KM *= pow(10, -6) * M_PI
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/test_" + String(describing: Date(timeIntervalSince1970: Date().timeIntervalSince1970)) + ".txt")
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
        
        NSLog("Initialized")
        
        NotificationCenter.default.addObserver(self, selector: #selector(GaugeVC.pinDataDidUpdate(_:)), name: NSNotification.Name.faobd2PIDDataUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isNavigationBarHidden = true
        
        // initialize views
        img_frameRight.image = UIImage(cgImage: img_frameRight.image!.cgImage!, scale: img_frameRight.image!.scale, orientation: UIImageOrientation.upMirrored)
        img_pivotRight.image = UIImage(cgImage: img_pivotRight.image!.cgImage!, scale: img_pivotRight.image!.scale, orientation: UIImageOrientation.upMirrored)
        
        /*if (switch_ignition.on) {
        rotate(img_needleLeft, degree: -45)
        rotate(img_needleRight, degree: -15)
        } else {
        gaugeOff();
        }*/
        
        rotate(img_needleLeft, degree: -45)
        rotate(img_needleRight, degree: -15)
        gaugeOff()
        
        label_gear.text = "1"
        curGear = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NSLog("connecting")
        (FAOBD2Communicator.sharedInstance() as AnyObject).startStreaming()
        
        /*let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
        while (true) {
        while (self.lastUpdated == -1) {
        NSLog("connecting")
        FAOBD2Communicator.sharedInstance().startStreaming()
        }
        if (CACurrentMediaTime() - self.lastUpdated > 1) {
        NSLog("connection lost")
        self.lastUpdated = -1
        self.gaugeOffAnim()
        }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        })
        })*/
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func pinDataDidUpdate(_ notification: Notification) {
        let notificationObject = (notification.object as! [String: Any])
        let sensor = notificationObject["sensor"] as! String
        
        if (lastUpdated == -1) {
            NSLog("connected")
            blockUpdate(NEEDLE_ON_DURATION  + 2 * GAUGE_SWEEP_DURATION, onPID: PID_ALL)
            gaugeOnAnim()
        }
        
        lastUpdated = CACurrentMediaTime()
        if (sensor  == PID_RPM) {
            NSLog("RPM: " + String(notificationObject["value"] as! Double))
            if (curRPM == 0) {
                updateRPM(notificationObject["value"] as! Double, duration: RPM_INIT_DURATION)
                blockUpdate(RPM_INIT_DURATION, onPID: PID_RPM)
            } else {
                updateRPM(notificationObject["value"] as! Double)
            }
        } else if (sensor == PID_SPEED) {
            NSLog("Speed: " + String(notificationObject["value"] as! Double))
            updateSpeed(notificationObject["value"] as! Double)
        }
    }
    
    func blockUpdate(_ forSec: Double, onPID: String) {
        blockDict[onPID] = (CACurrentMediaTime() as Double) + forSec
    }
    
    func updateBlocked(_ onPID: String) -> Bool {
        return ((CACurrentMediaTime() as Double) < blockDict[PID_ALL]) || ((CACurrentMediaTime() as Double) < blockDict[onPID])
    }
    
    func updateGear() {
        if (curSpeed == 0) {
            label_gear.text = "1"
        } else {
            let curTimesFnl = curRPM * 60 * WHEEL_CIRCUM_KM / curSpeed * SPEED_CALIBRATION_FACTOR
            label_gear.text = predictGear(curTimesFnl)
        }
    }
    
    func predictGear(_ curTimesFnl: Double) -> String {
        var mostLikelyGear:Int = 0
        var minGearRatioDiff:Double = 100.0
        
        var i, j: Int
        if (GEARBOX_AUTOMATIC) {
            i = max(curGear-2, 0)
            j = min(curGear+1, GEAR_RATIOS.count)
        } else {
            i = 0;
            j = GEAR_RATIOS.count
        }
        
        while (i < j) {
            i += 1
            let curGearRatio = GEAR_RATIOS[i]
            var curGearRatioDiff:Double = 100.0
            if (i <= 3) {
                curGearRatioDiff = abs(curTimesFnl / GEAR_RATIO_FINAL_1 - curGearRatio)
            } else {
                curGearRatioDiff = abs(curTimesFnl / GEAR_RATIO_FINAL_2 - curGearRatio)
            }
            if (curGearRatioDiff < minGearRatioDiff) {
                mostLikelyGear = i + 1
                minGearRatioDiff = curGearRatioDiff
            }
        }
        
        curGear = mostLikelyGear
        return String(mostLikelyGear)
    }
    
    func gaugeOffAnim() {
        UIView.animate(withDuration: GAUGE_OFF_DURATION, animations: {
            self.lastUpdated = -1
            self.gaugeOff()
        })
    }
    
    func gaugeOff() {
        // left
        img_frameLeft.alpha = 0.5
        img_pivotLeft.alpha = 0.75
        img_tachoScale.alpha = 0
        rotate(img_tachoScale, degree: 15)
        img_tachoRead.alpha = 0
        img_tachoUnit.alpha = 0
        img_needleLeft.alpha = 0
        rotate(img_needleLeft, degree: -30)
        label_gear.alpha = 0
        
        // middle
        img_smallGaugesFrame.alpha = 0.5
        
        // right
        img_frameRight.alpha = 0.5
        img_pivotRight.alpha = 0.75
        img_speedScale.alpha = 0
        rotate(img_speedScale, degree: -15)
        img_speedRead.alpha = 0
        img_speedUnit.alpha = 0
        img_needleRight.alpha = 0
        rotate(img_needleRight, degree: -30)
        label_speed.alpha = 0
    }
    
    func gaugeOnAnim() {
        UIView.animate(withDuration: NEEDLE_ON_DURATION, animations: {
            self.img_frameLeft.alpha = 0.65
            self.img_pivotLeft.alpha = 0.825
            self.img_needleLeft.alpha = 1
            self.img_frameRight.alpha = 0.65
            self.img_pivotRight.alpha = 0.825
            self.img_needleRight.alpha = 1
            }, completion: { finished in
                self.animateRotate(self.img_needleLeft, degree: 210, duration: GAUGE_SWEEP_DURATION, myValue: KEY_SWEEP)
                self.animateRotate(self.img_needleRight, degree: 210, duration: GAUGE_SWEEP_DURATION)
        })
        
    }
    
    func toggleIgnition(_ sender: UISwitch) {
        if (sender.isOn) {
            gaugeOnAnim()
        } else {
            gaugeOffAnim()
        }
    }
    
    func rotate(_ view: UIView, degree: Double) {
        view.transform = CGAffineTransform(rotationAngle: degToRad(degree))
    }
    
    func animateRotate(_ view: UIImageView, degree: Double, duration: Double, myValue: Int = -1, timingFunction: String = kCAMediaTimingFunctionEaseInEaseOut) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        var origDeg = Double(atan2(view.transform.b, view.transform.a));
        if (origDeg < -0.5 * M_PI) {
            origDeg += 2 * M_PI
        }
        rotationAnimation.fromValue = origDeg
        rotationAnimation.toValue = degToRad(degree)
        rotationAnimation.byValue = ((rotationAnimation.fromValue as! Double) + (rotationAnimation.toValue as! Double)) / 2
        
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = 1
        rotationAnimation.delegate = self
        
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        rotationAnimation.setValue(myValue, forKey: "rotationAnimation")
        
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        rotate(view, degree: degree)
    }
    
    func selectSpeed(_ sender: UISlider) {
        updateSpeed(Double(sender.value))
    }
    
    func updateSpeed(_ newSpeed: Double) {
        var newSpeed = newSpeed
        newSpeed *= SPEED_CALIBRATION_FACTOR
        curSpeed = newSpeed
        
        label_speed.text = String(Int(ceil(newSpeed)))
        
        var rotateDeg: Double = 0
        if (newSpeed <= 80) {
            rotateDeg = (newSpeed - 10) / 20 * 30
        } else if (newSpeed <= 160) {
            rotateDeg = (newSpeed - 80) / 40 * 30 + 105
        } else if (newSpeed <= 280) {
            rotateDeg = (newSpeed - 160) / 60 * 30 + 165
        }
        NSLog("Rotate: " + String(rotateDeg))
        
        if (!updateBlocked(PID_SPEED)) {
            blockUpdate(SPEED_GAUGE_UPDATE_DURATION, onPID: PID_SPEED)
            animateRotate(img_needleRight, degree: rotateDeg, duration: SPEED_GAUGE_UPDATE_DURATION, timingFunction: kCAMediaTimingFunctionLinear)
        }
    }
    
    func selectRPM(_ sender: UISlider) {
        updateRPM(Double(sender.value))
    }
    
    func updateRPM(_ newRPM: Double, duration: Double = RPM_GAUGE_UPDATE_DURATION) {
        curRPM = newRPM
        let rotateDeg = newRPM / 8000.0 * 240 - 45
        if (!updateBlocked(PID_RPM)) {
            animateRotate(img_needleLeft, degree: rotateDeg, duration: duration)
        }
        updateGear()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animValue = anim.value(forKey: "rotationAnimation") as! Int
        
        switch(animValue) {
        case KEY_SWEEP:
            self.animateRotate(self.img_needleLeft, degree: -45, duration: GAUGE_SWEEP_DURATION)
            self.animateRotate(self.img_needleRight, degree: -15, duration: GAUGE_SWEEP_DURATION, myValue: KEY_SWEEP_BACK)
            UIView.animate(withDuration: GAUGE_SWEEP_DURATION, animations: {
                // left
                self.img_frameLeft.alpha = 1
                self.img_pivotLeft.alpha = 1
                self.img_tachoScale.alpha = 1
                self.rotate(self.img_tachoScale, degree: 0)
                self.img_tachoRead.alpha = 1
                self.img_tachoUnit.alpha = 1
                self.label_gear.alpha = 1
                
                //middle
                self.img_smallGaugesFrame.alpha = 1
                
                // right
                self.img_frameRight.alpha = 1
                self.img_pivotRight.alpha = 1
                self.img_speedScale.alpha = 1
                self.rotate(self.img_speedScale, degree: 0)
                self.img_speedRead.alpha = 1
                self.img_speedUnit.alpha = 1
                self.label_speed.alpha = 1
            })
            break;
        case KEY_SWEEP_BACK:
            usleep(300*1000)
        default:
            break;
        }
    }
    
    func degToRad(_ degree: Double)->CGFloat {
        return CGFloat(degree * M_PI / 180)
    }
    
}
