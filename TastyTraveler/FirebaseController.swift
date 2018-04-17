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
            let isUnique = !usernames.contains(where: { (key, value) -> Bool in
                key == username.lowercased()
            })
            completion(isUnique)
        }
    }
    
    func isUsernameStored(uid: String, completion: @escaping (Bool) -> Void) {
        
        self.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            // Get value
            let value = snapshot.value as? NSDictionary
            completion(value?["username"] != nil)
        }
    }
    
    func storeUsername(_ username: String, uid: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.ref.child("users").child(uid).setValue(["username": username])
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
        
        let localData = dictionary[Recipe.photoKey] as! Data
        
        let recipeID = UUID().uuidString
        let imageFileRef = storageRef.child("images/\(recipeID)")
        let thumbnailFileRef = storageRef.child("thumbnails/\(recipeID)")
        let videoFileRef = storageRef.child("videos/\(recipeID)")
        
        let _ = imageFileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            
            guard let photoURL = metadata.downloadURL()?.absoluteString else { print("no download url"); return }
            
            let timestamp = Date().timeIntervalSince1970
            
            let recipeName = dictionary[Recipe.nameKey] as! String
            
            var dictionaryToUpload: [String:Any] = [Recipe.nameKey: recipeName,
                                                    "timestamp": timestamp,
                                                    Recipe.photoURLKey: photoURL,
                                                    Recipe.creatorIDKey: currentUser.uid,
                                                    Recipe.servingsKey: dictionary[Recipe.servingsKey] as! Int,
                                                    Recipe.timeInMinutesKey: dictionary[Recipe.timeInMinutesKey] as! Int,
                                                    Recipe.difficultyKey: dictionary[Recipe.difficultyKey] as! String,
                                                    Recipe.ingredientsKey: dictionary[Recipe.ingredientsKey] as! [String],
                                                    Recipe.stepsKey: dictionary[Recipe.stepsKey] as! [String]]
            
            if let tags = dictionary[Recipe.tagsKey] as? [String] {
                dictionaryToUpload[Recipe.tagsKey] = tags
            }
            
            if let description = dictionary[Recipe.descriptionKey] as? String {
                dictionaryToUpload[Recipe.descriptionKey] = description
            }
            
            self.ref.child("recipes").child(recipeID).setValue(dictionaryToUpload)
            
            self.ref.child("users").child(currentUser.uid).child("uploadedRecipes").child(recipeID).setValue(true)
            
            NotificationCenter.default.post(Notification(name: Notification.Name("RecipeUploaded")))
            
            if let videoURL = dictionary[Recipe.videoURLKey] as? URL {
                let _ = videoFileRef.putFile(from: videoURL, metadata: nil) { (videoMetadata, error) in
                    guard let videoMetadata = videoMetadata else { return }
                    guard let uploadedVideoURL = videoMetadata.downloadURL()?.absoluteString else { print("no video download url"); return }
                    
                    let thumbnailData = dictionary[Recipe.thumbnailURLKey] as! Data
                    let _ = thumbnailFileRef.putData(thumbnailData, metadata: nil, completion: { (thumbnailMetadata, error) in
                        guard let thumbnailMetadata = thumbnailMetadata else { return }
                        guard let thumbnailURL = thumbnailMetadata.downloadURL()?.absoluteString else { print("no thumbnail download url"); return }
                        
                        self.ref.child("recipes").child(recipeID).updateChildValues([Recipe.thumbnailURLKey: thumbnailURL])
                    })
                    
                    self.ref.child("recipes").child(recipeID).updateChildValues([Recipe.videoURLKey: uploadedVideoURL])
                }
            }
        }
    }

}
