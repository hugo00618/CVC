//
//  AppDelegate.swift
//  CVC
//
//  Created by Hugo Yu on 2015-11-27.
//  Copyright © 2015 Hugo Yu. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setUpGrp();
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "info.hugoyu.CVC" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "CVC", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func setUpGrp() {
        let userDefaults:UserDefaults = UserDefaults.standard
        // create Grear Ratio Presets if needed
        var encodedGrps = userDefaults.object(forKey: KEY_GEAR_RATIO_PRESETS) as? [String: [Data]]
        if (encodedGrps == nil) {
            encodedGrps = [String: [Data]]()
        }
        encodedGrps!["Audi"] = [Data]()
        encodedGrps!["SEAT"] = [Data]()
        encodedGrps!["Skoda"] = [Data]()
        encodedGrps!["Volkswagen"] = [Data]()
        
        var myGrp: GearRatioProfile;
        
        myGrp = GearRatioProfile(name: "VAG AQ250-6F 6-Speed Tiptronic", gearRatios: [4.148,2.37,1.556,1.155,0.859,0.686], finalDriveRatios: [3.867], fdrMaxGears: [5])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        myGrp = GearRatioProfile(name: "VAG DQ200 7-Speed DSG", gearRatios: [3.764,2.272,1.531,1.121,1.176,0.951,0.795], finalDriveRatios: [4.437,3.227], fdrMaxGears: [3,6])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        myGrp = GearRatioProfile(name: "VAG DQ250 6-Speed DSG (Configuration 1)", gearRatios: [3.461,2.05,1.3,0.9,0.91,0.76], finalDriveRatios: [4.12,3.04], fdrMaxGears: [3,5])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        myGrp = GearRatioProfile(name: "VAG DQ250 6-Speed DSG (Configuration 2)", gearRatios: [3.461,2.15,1.464,1.078,1.093,0.921], finalDriveRatios: [4.059,3.14], fdrMaxGears: [3,5])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        myGrp = GearRatioProfile(name: "VAG MQ200-5F 5-Speed Manual (Configuration 1)", gearRatios: [3.769,2.095,1.433,1.079,0.851], finalDriveRatios: [4.533], fdrMaxGears: [4])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        myGrp = GearRatioProfile(name: "VAG MQ200-5F 5-Speed Manual (Configuration 2)", gearRatios: [3.788,2.063,1.348,0.967,0.744], finalDriveRatios: [3.389], fdrMaxGears: [4])
        encodedGrps!["Audi"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["SEAT"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Skoda"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        encodedGrps!["Volkswagen"]!.append(NSKeyedArchiver.archivedData(withRootObject: myGrp))
        
        
        
        
        userDefaults.set(encodedGrps, forKey: KEY_GEAR_RATIO_PRESETS)
        // create User-Defined Gear Ratio Profiles if needed
        let encodedUdgrps = userDefaults.object(forKey: KEY_USER_DEFINED_GEAR_RATIO_PROFILES) as? Data
        if (encodedUdgrps == nil) {
            let udgrps = [GearRatioProfile]()
            userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: udgrps), forKey: KEY_USER_DEFINED_GEAR_RATIO_PROFILES)
        }
    }
    
}

