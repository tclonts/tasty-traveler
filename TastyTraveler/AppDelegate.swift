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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        #if DEBUG
//        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")
//        #else
        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
//        #endif
        
        guard let options = FirebaseOptions(contentsOfFile: firebaseConfig!) else {
            fatalError("Invalid Firebase configuration file.")
        }
        
        attemptRegisterForNotifications(application: application)
        
        FirebaseApp.configure(options: options)
        
        window = UIWindow()
        
        window?.rootViewController = LaunchScreenVC()
        
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { (error) in
                if let error = error {
                    let code = (error as NSError).code
                    if code == AuthErrorCode.userNotFound.rawValue {
                        do {
                            try Auth.auth().signOut()
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                    self.window?.rootViewController = AccountAccessVC()
                } else {
                    FirebaseController.shared.isUsernameStored(uid: Auth.auth().currentUser!.uid, completion: { (result) in
                        if result {
                            self.window?.rootViewController = MainTabBarController()
                        } else {
                            let signUpVC = SignUpVC()
                            signUpVC.needsUsername = true
                            signUpVC.isFromFacebookLogin = true
                            self.window?.rootViewController = signUpVC
                        }
                    })
                }
            })
        } else {
            window?.rootViewController = AccountAccessVC()
        }
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
        FirebaseController.shared.saveToken()
    }
    
    private func attemptRegisterForNotifications(application: UIApplication) {
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {granted, error in
            if let error = error {
                print("Failed to request auth:", error)
                return
            }
            
            if granted {
                print("Auth granted.")
            } else {
                print("Auth denied.")
            }
        })
        
        application.registerForRemoteNotifications()
    }
    
    // listen for user notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //completionHandler(.alert)
    }
    
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
