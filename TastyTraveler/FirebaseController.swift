//
//  FirebaseController.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/26/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Firebase
import UIKit

class FirebaseController {
    static var shared = FirebaseController()
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    func verifyUniqueUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        let usernamesRef = self.ref.child("usernames")
        usernamesRef.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else { completion(true); return }
            guard let usernames = snapshot.value as? [String:Any] else { return }
            let isUnique = usernames.contains(where: { (key, value) -> Bool in
                key != username.lowercased()
            })
            completion(isUnique)
        }
    }
    
    func storeUsername(_ username: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.ref.child("users").child(currentUser.uid).setValue(["username": username])
                self.ref.child("usernames").child(username.lowercased()).setValue(true)
                
                let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                if isRegisteredForRemoteNotifications { self.saveToken() }
            }
        }
    }
    
    func saveToken() {
        guard let uid = Auth.auth().currentUser?.uid, let token = Messaging.messaging().fcmToken else { return }
        
        self.ref.child("users").child(uid).child("notificationToken").child(token).setValue(true)
    }
    
    func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        self.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String:Any] else { return }
            
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
        }
    }
    
    func uploadRecipe(dictionary: [String:Any]) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let localData = dictionary["photo"] as! Data
        let recipeID = UUID().uuidString
        let fileRef = storageRef.child("images/\(recipeID)")
        
        let _ = fileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            
            guard let photoURL = metadata.downloadURL()?.absoluteString else { print("no download url"); return }
            
            let timestamp = Date().timeIntervalSince1970
            
            let recipeName = dictionary["recipeName"] as! String
            
            
            self.ref.child("recipes").child(recipeID).setValue(["recipeName": recipeName, "timestamp": timestamp, "photoURL": photoURL, "creatorID": currentUser.uid])
            
            self.ref.child("users").child(currentUser.uid).child("uploadedRecipes").child(recipeID).setValue(true)
        }
    }

}
