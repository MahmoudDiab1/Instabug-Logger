//
//  AppDelegate.swift
//  InstabugInternshipTask
//
//  Created by Yosef Hamza on 19/04/2021.
//

import UIKit
import InstabugLogger
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        
        // MARK:- Configure InstabugLogger -
        
        /// Custom configuration
        ///
        /// let customConfigurations = StorageConfiguration(storageType: .coreData, limit: 2500)
        /// InstabugLogger.shared.configure(configurations: customConfigurations)
        
        
        /// Default configuration
        InstabugLogger.shared.configure()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }  
}

