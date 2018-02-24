//
//  AppDelegate.swift
//  Bite
//
//  Created by Jamie Nguyen on 2/23/18.
//  Copyright © 2018 Jamie Nguyen. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    
    func applicationWillResignActive(_ application: UIApplication) {
        stack.save()
        
    }
    // MARK: - Core Data stack
    let stack = CoreDataStack(modelName: "Bite")!
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        stack.save()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Start Autosaving
        stack.autoSave(60)
        return true
    }

}

