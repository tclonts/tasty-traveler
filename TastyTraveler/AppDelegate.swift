//
//  AppDelegate.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/2/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
//    var fontModifier: CGFloat = 0
//    let ScreenHeight = Int(UIScreen.main.bounds.size.height)
//    let iPhoneSEHeight = 568
//    let iPhone8Height = 667
//    let iPhone8PlusHeight = 736
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        #if DEBUG
//        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")
//        #else
        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
//        #endif
        
        guard let options = FirebaseOptions(contentsOfFile: firebaseConfig!) else {
            fatalError("Invalid Firebase configuration file.")
        }
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure(options: options)
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
        window = UIWindow()
//        setFontModifier()
        
//        do {
//            try Auth.auth().signOut()
//
//        } catch let signOutError as NSError {
//            print("Error signing out: \(signOutError)")
//        }
        
        if Auth.auth().currentUser == nil {
            window?.rootViewController = AccountAccessVC()
        } else {
            window?.rootViewController = MainTabBarController()
        }
        
        return true
    }
    
//    func setFontModifier() {
//        switch ScreenHeight {
//        case iPhoneSEHeight:
//            fontModifier = 2
//        default:
//            fontModifier = 0
//        }
//    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
