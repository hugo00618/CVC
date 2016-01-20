//
//  GaugeViewController.swift
//  CVC
//
//  Created by Hugo Yu on 2015-11-27.
//  Copyright © 2015 Hugo Yu. All rights reserved.
//

import UIKit

class GaugeViewController: UIViewController {
    
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
    
    @IBOutlet weak var slider_speedometer: UISlider!
    @IBOutlet weak var slider_tachometer: UISlider!
    @IBOutlet weak var switch_ignition: UISwitch!
    
    @IBOutlet weak var label_speed: UILabel!
    @IBOutlet weak var label_gear: UILabel!
    
    let NEEDLE_ON_DURATION = 0.3
    let GAUGE_SWEEP_DURATION = 0.8 // one-way
    let GAUGE_UPDATE_DURATION = 0.3
    let GAUGE_OFF_DURATION = 0.5
    
    let KEY_SWEEP = 1
    let KEY_SWEEP_BACK = 2
    
    var curRPM = Double(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DEBUG
        slider_speedometer.addTarget(self, action: "selectSpeed:", forControlEvents: UIControlEvents.ValueChanged)
        slider_tachometer.addTarget(self, action: "selectRPM:", forControlEvents: UIControlEvents.ValueChanged)
        switch_ignition.addTarget(self, action: "toggleIgnition:", forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pinDataDidUpdate:", name: kFAOBD2PIDDataUpdatedNotification, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBarHidden = true
        
        // initialize views
        img_frameRight.image = UIImage(CGImage: img_frameRight.image!.CGImage!, scale: img_frameRight.image!.scale, orientation: UIImageOrientation.UpMirrored)
        img_pivotRight.image = UIImage(CGImage: img_pivotRight.image!.CGImage!, scale: img_pivotRight.image!.scale, orientation: UIImageOrientation.UpMirrored)
        
        /*if (switch_ignition.on) {
        rotate(img_needleLeft, degree: -45)
        rotate(img_needleRight, degree: -15)
        } else {
        gaugeOff();
        }*/
        rotate(img_needleLeft, degree: -45)
        rotate(img_needleRight, degree: -15)
        gaugeOff()
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*while (curRPM == 0) {
            NSLog("connecting...")
            FAOBD2Communicator.sharedInstance().startStreaming()
        }
        gaugeOnAnim()*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
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
    
    func pinDataDidUpdate(notification: NSNotification) {
        var sensor = notification.object?["sensor"] as! String
        if (sensor  == kFAOBD2PIDVehicleRPM) {
            NSLog("RPM: " + (notification.object?["value"] as! String))
            updateRPM(notification.object?["value"] as! Double)
        } else if (sensor == kFAOBD2PIDVehicleSpeed) {
            NSLog("Speed: " + (notification.object?["value"] as! String))
            updateSpeed(notification.object?["value"] as! Int)
        }
        
    }
    
    func gaugeOffAnim() {
        UIView.animateWithDuration(GAUGE_OFF_DURATION, animations: {
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
        UIView.animateWithDuration(NEEDLE_ON_DURATION, animations: {
            self.img_frameLeft.alpha = 0.65
            self.img_pivotLeft.alpha = 0.825
            self.img_needleLeft.alpha = 1
            self.img_frameRight.alpha = 0.65
            self.img_pivotRight.alpha = 0.825
            self.img_needleRight.alpha = 1
            }, completion: { finished in
                self.animateRotate(self.img_needleLeft, degree: 210, duration: self.GAUGE_SWEEP_DURATION, myValue: self.KEY_SWEEP)
                self.animateRotate(self.img_needleRight, degree: 210, duration: self.GAUGE_SWEEP_DURATION)
        })
        
    }
    
    func toggleIgnition(sender: UISwitch) {
        if (sender.on) {
            NSLog("connecting...")
            FAOBD2Communicator.sharedInstance().startStreaming()
            gaugeOnAnim()
        } else {
            gaugeOffAnim()
        }
    }
    
    func rotate(view: UIView, degree: Double) {
        view.transform = CGAffineTransformMakeRotation(degToRad(degree))
    }
    
    func animateRotate(view: UIImageView, degree: Double, duration: Double, myValue: Int? = -1) {
        var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        
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
        
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        rotationAnimation.setValue(myValue, forKey: "rotationAnimation")
        
        view.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        rotate(view, degree: degree)
    }
    
    func selectSpeed(sender: UISlider) {
        updateSpeed(Int(sender.value))
    }
    
    func updateSpeed(newSpeed: Int) {
        label_speed.text = String(newSpeed)
        
        var rotateDeg: Double = 0
        if (newSpeed <= 80) {
            rotateDeg = (Double(newSpeed) - 10) / 20 * 30
        } else if (newSpeed <= 160) {
            rotateDeg = (Double(newSpeed) - 80) / 40 * 30 + 105
        } else if (newSpeed <= 280) {
            rotateDeg = (Double(newSpeed) - 160) / 60 * 30 + 165
        }
        animateRotate(img_needleRight, degree: rotateDeg, duration: GAUGE_UPDATE_DURATION)
    }
    
    func selectRPM(sender: UISlider) {
        updateRPM(Double(sender.value))
    }
    
    func updateRPM(newRPM: Double) {
        curRPM = newRPM
        NSLog(String(newRPM))
        var rotateDeg = newRPM / 8000.0 * 240 - 45
        animateRotate(img_needleLeft, degree: rotateDeg, duration: GAUGE_UPDATE_DURATION)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        var animValue = anim.valueForKey("rotationAnimation") as! Int
        
        switch(animValue) {
        case KEY_SWEEP:
            self.animateRotate(self.img_needleLeft, degree: -45, duration: GAUGE_SWEEP_DURATION)
            self.animateRotate(self.img_needleRight, degree: -15, duration: GAUGE_SWEEP_DURATION, myValue: KEY_SWEEP_BACK)
            UIView.animateWithDuration(GAUGE_SWEEP_DURATION, animations: {
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
            updateSpeed(Int(slider_speedometer.value))
            updateRPM(Double(slider_tachometer.value))
        default:
            break;
        }
    }
    
    func degToRad(degree: Double)->CGFloat {
        return CGFloat(degree * M_PI / 180)
    }
    
}
