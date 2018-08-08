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
import FBSDKCoreKit.FBSDKAppLinkUtility

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
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) in
            if let error = error { print(error); return }
            
            if let url = url {
                print(url)
            }
        }
        
        FirebaseApp.configure(options: options)
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow()
        let launchVC = LaunchScreenVC()
        
        window?.rootViewController = launchVC
        
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { (error) in
                if let error = error {
//                    let code = (error as NSError).code
//                    if code == AuthErrorCode.userNotFound.rawValue {
//                        do {
//                            try Auth.auth().signOut()
//                        } catch let error {
//                            print(error.localizedDescription)
//                        }
//                    }
//                    let accountAccessVC = AccountAccessVC()
//                    self.window?.rootViewController = accountAccessVC
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
            if let browsing = UserDefaults.standard.value(forKey: "isBrowsing") as? Bool, browsing {
                self.window?.rootViewController = MainTabBarController()
            } else {
                let accountAccessVC = AccountAccessVC()
                window?.rootViewController = accountAccessVC
            }
        }
        
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Registered with FCM with token:", fcmToken)
    }
    
    
    
    // listen for user notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //completionHandler(.alert)
        print("WILL PRESENT NOTIFICATION CALLED")
   
        let application = UIApplication.shared
        if application.applicationState == .active {
            application.applicationIconBadgeNumber = 0
            FirebaseController.shared.resetBadgeCount()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        FirebaseController.shared.saveToken()
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
        AppEventsLogger.activate(application)
        let defaults = UserDefaults.standard
        
        var numberOfTimesLaunched = defaults.object(forKey: "TimesLaunched") as? Int ?? 0
        numberOfTimesLaunched += 1
        defaults.set(numberOfTimesLaunched, forKey: "TimesLaunched")
        
        if numberOfTimesLaunched >= 3 {
            attemptRegisterForNotifications(application: application, completion: { (complete) in
                if complete { print("Registered for notifications.") }
            })
        }
        
        application.applicationIconBadgeNumber = 0
        FirebaseController.shared.resetBadgeCount()
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
}




func attemptRegisterForNotifications(application: UIApplication, completion: @escaping (Bool) -> ()) {
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {granted, error in
        if let error = error {
            print("Failed to request auth:", error)
            completion(false)
            return
        }
        
        if granted {
            print("Auth granted.")
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
            
            FirebaseController.shared.ref.child("users").child(userID).child("notificationSettings").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists() {
                    let dict = [UserNotificationType.cooked.rawValue: true,
                                UserNotificationType.favorited.rawValue: true,
                                UserNotificationType.message.rawValue: true,
                                UserNotificationType.review.rawValue: true]
                    FirebaseController.shared.ref.child("users").child(userID).child("notificationSettings").updateChildValues(dict)
                    completion(true)
                } else { completion(true) }
            })
        } else {
            print("Auth denied.")
            completion(false)
        }
    })
    
}
