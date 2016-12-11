//
//  AppDelegate.swift
//  ecoh
//
//  Created by Ryan Chiu on 5/28/16.
//  Copyright © 2016 Ecoh Technologies, LLC. All rights reserved.
//

import UIKit
import CoreData

import Firebase
import FirebaseMessaging
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Firebase
        FIRApp.configure()
        
        // Register for remote notifications
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)
        
        // Initialize Places API
        GMSServices.provideAPIKey("AIzaSyC444GK-o4gk85z2A1k_QQSEISvzHpQ6Pk")
        //GooglePlaces.provideAPIKey("AIzaSyC444GK-o4gk85z2A1k_QQSEISvzHpQ6Pk")
        
        // Set status bar to light color
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // Customize page controller for walkthrough
        let pageController = UIPageControl.appearance()
        pageController.pageIndicatorTintColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5)
        pageController.currentPageIndicatorTintColor = UIColor.whiteColor()

        // If user has logged in before (session saved), then log in immediately
        if let email = NSUserDefaults.standardUserDefaults().valueForKey("email") {
            if let password = NSUserDefaults.standardUserDefaults().valueForKey("password") {
                FIRAuth.auth()?.signInWithEmail(email as! String, password: password as! String) { (user, error) in
                    if error != nil {
                        print("Error: Login w/ NSUserDefaults failed.")
                    } else {
                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Reveal") as UIViewController
                        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                        self.window?.rootViewController = initialViewController
                        self.window?.makeKeyAndVisible()
                    }
                }
            } else {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Start") as UIViewController
                self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        } else {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController : UIViewController = storyboard.instantiateViewControllerWithIdentifier("Start") as UIViewController
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ecoh.ecoh" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ecoh", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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

}

