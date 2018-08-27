//
//  FirebaseController.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/26/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Firebase
import UIKit
import SVProgressHUD
import FacebookCore

class FirebaseController {
    static var shared = FirebaseController()
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    var userNotifications = [UserNotification]()
    
    var unreadMessagesCount = 0
    var unreadNotificationsCount = 0 {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("UnreadNotification"), object: nil)
        }
    }
    var messages = [Message]()
    var messagesDictionary = [String:[String:Message]]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userMessagesRef = self.ref.child("userMessages").child(uid)
        
        userMessagesRef.observe(.childAdded) { (snapshot) in
            let userID = snapshot.key
            userMessagesRef.child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                self.fetchMessage(withID: messageID)
            })
        }
        
        userMessagesRef.observe(.childRemoved) { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReload()
        }
        
        let messagesRef = self.ref.child("messages")
        
        messagesRef.observe(.childChanged) { (snapshot) in
            if let messageDict = snapshot.value as? [String:Any] {
                let message = Message(uid: snapshot.key, dictionary: messageDict)
                
                guard message.toID == uid else { return }
                
                if let chatPartnerID = message.chatPartnerID() {
                    if let recipeID = message.recipeID {
                        if let existingMessage = self.messagesDictionary[chatPartnerID]?[recipeID],
                            existingMessage.uid == message.uid {
                            self.messagesDictionary[chatPartnerID]!.updateValue(message, forKey: recipeID)
                            self.attemptReload()
                        }
                    } else {
                        if let existingMessage = self.messagesDictionary[chatPartnerID]?["welcomeMessage"], existingMessage.uid == message.uid {
                            self.messagesDictionary[chatPartnerID]!.updateValue(message, forKey: "welcomeMessage")
                            self.attemptReload()
                        }
                    }
                }
            }
        }
    }
    
    func fetchMessage(withID messageID: String) {
        let messagesRef = ref.child("messages").child(messageID)
        
        messagesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let message = Message(uid: snapshot.key, dictionary: dictionary)
                
                if let chatPartnerID = message.chatPartnerID() {
                    if let recipeID = message.recipeID {
                        if self.messagesDictionary[chatPartnerID] == nil {
                            self.messagesDictionary[chatPartnerID] = [recipeID: message]
                        } else {
                            self.messagesDictionary[chatPartnerID]!.updateValue(message, forKey: recipeID)
                        }
                    } else {
                        if self.messagesDictionary[chatPartnerID] == nil {
                            self.messagesDictionary[chatPartnerID] = ["welcomeMessage": message]
                        } else {
                            self.messagesDictionary[chatPartnerID]!.updateValue(message, forKey: "welcomeMessage")
                        }
                    }
                }
                self.attemptReload()
            }
        }
    }
    
    var timer: Timer?
    
    @objc func attemptReload() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        // one message for each recipeID.
        self.messages.removeAll()
        self.messagesDictionary.forEach { (key, value) in
            // chatPartnerID: [recipeID: Message, recipeID: Message, recipeID: Message]
            let recipeIDMessagePairs: [String:Message] = value
            self.messages.append(contentsOf: recipeIDMessagePairs.values)
        }
        
        self.messages.sort { (m1, m2) -> Bool in
            return m1.timestamp.compare(m2.timestamp) == .orderedDescending
        }
        
        NotificationCenter.default.post(name: Notification.Name("ReloadMessages"), object: nil)
    }
    
    func observeUnreadMessagesCount() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userID).child("unreadMessagesCount").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? Int else { print("unreadMessagesCount not found."); return }
            
            self.unreadMessagesCount = value
            NotificationCenter.default.post(name: Notification.Name("UpdateTabBadge"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("UpdateTitle"), object: nil)
        }
    }
    
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
    
    func isUsernameStored(uid: String, completion: @escaping (Bool) -> ()) {
        print("Verifying username exists.")
        self.ref.child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            // Get value
            if let value = snapshot.value as? String {
                print(value)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func resetBadgeCount() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //badgeCount = 0
        self.ref.child("users").child(uid).child("badgeCount").setValue(0)
    }
    
    func storeUsername(_ username: String, uid: String, completion: @escaping (Bool) -> ()) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = username
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.ref.child("users").child(uid).child("username").setValue(username)
                self.ref.child("usernames").child(username.lowercased()).setValue(true)
                
                completion(true)
                
                let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
                if isRegisteredForRemoteNotifications { self.saveToken() }
            }
        }
    }
    
    func saveToken() {
        guard let uid = Auth.auth().currentUser?.uid, let token = Messaging.messaging().fcmToken else { return }
        
        self.ref.child("users").child(uid).child("notificationToken").setValue(token)
    }
    
    func fetchUserWithUID(uid: String, completion: @escaping (TTUser?) -> ()) {
        self.ref.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String:Any] else { completion(nil); return }
            
            let user = TTUser(uid: uid, dictionary: userDictionary)
            completion(user)
        }
    }
    
    func observeNotifications() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let last25NotificationsQuery = self.ref.child("users").child(userID).child("notifications").queryLimited(toLast: 25)
        last25NotificationsQuery.observe(.childAdded) { (snapshot) in
            guard let notificationDict = snapshot.value as? [String:Any] else { return }
            
            guard let userID = notificationDict["userID"] as? String else { return }
            
            self.fetchUserWithUID(uid: userID, completion: { (user) in
                guard let user = user else { print("Could not retrieve user data"); return }
                
                let userNotification = UserNotification(uid: snapshot.key, user: user, dictionary: notificationDict)
                
                self.userNotifications.append(userNotification)
//                self.userNotifications.sort(by: { (n1, n2) -> Bool in
//                    n1.creationDate > n2.creationDate
//                })
                if userNotification.isUnread { self.unreadNotificationsCount += 1; NotificationCenter.default.post(name: Notification.Name("UpdateTabBadge"), object: nil) }
                NotificationCenter.default.post(name: Notification.Name("ReloadNotifications"), object: nil)
            })
        }
    }
    
    func fetchUserReview(forRecipeID recipeID: String, completion: @escaping (Review?) -> ()) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(nil); return }
        
        //    users > userID > reviewedRecipes > recipeID = reviewID
        FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").child(recipeID).observeSingleEvent(of: .value) { (snapshot) in
            guard let reviewID = snapshot.value as? String else { completion(nil); return }
            
            FirebaseController.shared.ref.child("reviews").child(reviewID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let reviewDictionary = snapshot.value as? [String:Any] else { completion(nil); return }
                
                completion(Review(uid: reviewID, dictionary: reviewDictionary))
            })
        }
    }
    
    func saveReview(_ review: Review, forRecipeID recipeID: String) {
        guard let userID = Auth.auth().currentUser?.uid, let reviewID = review.uid else { return }
        
        var dictionaryToUpload = [String:Any]()
        
        if let title = review.title {
            dictionaryToUpload["title"] = title
        }
        
        if let text = review.text {
            dictionaryToUpload["text"] = text
        }
        
        if let rating = review.rating {
            dictionaryToUpload["rating"] = rating
        }
        
        dictionaryToUpload["reviewerID"] = review.reviewerID
        dictionaryToUpload["recipeID"] = review.recipeID
        
        let timestamp = Date().timeIntervalSince1970
        dictionaryToUpload["timestamp"] = timestamp
        
//        var uid: String!
//        var title: String?
//        var text: String?
//        var rating: Int?
//        var user: User!
//        var creationDate: Date!
        
        ref.child("reviews").child(reviewID).updateChildValues(dictionaryToUpload) { (_, _) in
            self.ref.child("users").child(userID).child("reviewedRecipes").updateChildValues([recipeID: reviewID]) { (_,_) in
                self.ref.child("recipes").child(recipeID).child("reviews").updateChildValues([userID: reviewID]) { (_, _) in
                    NotificationCenter.default.post(name: Notification.Name("submittedReview"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name("FavoritesChanged"), object: nil)
                }
            }
        }
    }
    
    func fetchRecipeWithUID(uid: String, completion: @escaping (Recipe?) -> ()) {
        self.ref.child("recipes").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let recipeDictionary = snapshot.value as? [String:Any] else { return }
            guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String else { return }
            
            self.fetchUserWithUID(uid: creatorID, completion: { (user) in
                guard let user = user else { completion(nil); return }
                let recipe = Recipe(uid: uid, creator: user, dictionary: recipeDictionary)
                completion(recipe)
            })
        }
    }
    
    func uploadCookedRecipeImage(recipe: Recipe, data: Data) {
        
        guard let userID = Auth.auth().currentUser?.uid else {return }
        
        let localData = data
        let identifier = recipe.uid
        let fileRef = storageRef.child("recipes/\(identifier)")
        
        let uploadTask = fileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            guard let downloadURL = metadata.downloadURL()?.absoluteString else { print("No Download URL"); return }
            
            // store downloadURL at database
            self.ref.child("recipes").child(recipe.uid).child("cookedImages").setValue([userID: downloadURL])
            
//            let changeRequest = recipe.createProfileChangeRequest()
//            changeRequest.photoURL = URL(string: downloadURL)
//            changeRequest.commitChanges { (error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { (snapshot) in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { (snapshot) in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // Upload completed successfully
            // store downloadURL
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
        
        
        
    }
    
    
    func uploadProfilePhoto(data: Data) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        
        let localData = data
        let identifier = currentUser.uid
        let fileRef = storageRef.child("avatars/\(identifier)")
        
        let uploadTask = fileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            guard let downloadURL = metadata.downloadURL()?.absoluteString else { print("No Download URL"); return }
            
            // store downloadURL at database
            self.ref.child("users").child(currentUser.uid).child("avatarURL").setValue(downloadURL)
            
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.photoURL = URL(string: downloadURL)
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { (snapshot) in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { (snapshot) in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print(percentComplete)
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // Upload completed successfully
            // store downloadURL
            
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    func uploadTestRecipe(named name: String, longitude: Double, latitude: Double) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let recipeID = UUID().uuidString
        let photoURL = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Good_Food_Display_-_NCI_Visuals_Online.jpg/1200px-Good_Food_Display_-_NCI_Visuals_Online.jpg"
        let timestamp = Date().timeIntervalSince1970
        
        let recipeName = name
        
        let dictionaryToUpload: [String:Any] = [
            Recipe.nameKey: recipeName,
            "timestamp": timestamp,
            Recipe.photoURLKey: photoURL,
            Recipe.creatorIDKey: currentUser.uid,
            "longitude": longitude,
            "latitude": latitude,
            Recipe.servingsKey: 4,
            Recipe.timeInMinutesKey: 30,
            Recipe.difficultyKey: "Easy",
            Recipe.ingredientsKey: ["One", "Two", "Three", "Four"],
            Recipe.stepsKey: ["Step One", "Step Two", "Step Three", "Step Four"],
            Recipe.mealKey: "Lunch",
            Recipe.tagsKey: ["Gluten-free", "Vegetarian", "Organic"],
            Recipe.descriptionKey: "This is an example description.",
            Recipe.countryCodeKey: "US",
            Recipe.countryKey: "United States",
            Recipe.localityKey: "Florida"
        ]
        
        self.ref.child("localities").updateChildValues(["Florida": true])
        
        self.ref.child("recipes").child(recipeID).setValue(dictionaryToUpload)
        self.ref.child("users").child(currentUser.uid).child("uploadedRecipes").child(recipeID).setValue(true)
        
        NotificationCenter.default.post(Notification(name: Notification.Name("RecipeUploaded")))
        
        SVProgressHUD.showSuccess(withStatus: "Recipe uploaded!")
        SVProgressHUD.dismiss(withDelay: 0.5)
    }
    
    func updateRecipe(dictionary: [String:Any], uid: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
    }
    
    func uploadRecipe(dictionary: [String:Any], uid: String?, timestamp: Double?) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard let localData = dictionary[Recipe.photoKey] as? Data else { return }
        
        let recipeID = uid ?? UUID().uuidString
        let imageFileRef = storageRef.child("images/\(recipeID)")
        let thumbnailFileRef = storageRef.child("thumbnails/\(recipeID)")
        let videoFileRef = storageRef.child("videos/\(recipeID)")
        
        let _ = imageFileRef.putData(localData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            
            guard let photoURL = metadata.downloadURL()?.absoluteString else { print("no download url"); return }
            
            let timestamp = timestamp ?? Date().timeIntervalSince1970
            
            let recipeName = dictionary[Recipe.nameKey] as! String
            
            var dictionaryToUpload: [String:Any] = [Recipe.nameKey: recipeName,
                                                    "timestamp": timestamp,
                                                    Recipe.photoURLKey: photoURL,
                                                    Recipe.creatorIDKey: currentUser.uid,
                                                    Recipe.servingsKey: dictionary[Recipe.servingsKey] as! Int,
                                                    Recipe.timeInMinutesKey: dictionary[Recipe.timeInMinutesKey] as! Int,
                                                    Recipe.difficultyKey: dictionary[Recipe.difficultyKey] as! String,
                                                    Recipe.ingredientsKey: dictionary[Recipe.ingredientsKey] as! [String],
                                                    Recipe.stepsKey: dictionary[Recipe.stepsKey] as! [String],
                                                    Recipe.mealKey: dictionary[Recipe.mealKey] as! String]
            
            if let tags = dictionary[Recipe.tagsKey] as? [String] {
                dictionaryToUpload[Recipe.tagsKey] = tags
            }
            
            if let description = dictionary[Recipe.descriptionKey] as? String {
                dictionaryToUpload[Recipe.descriptionKey] = description
            }
            
            if let countryCode = dictionary[Recipe.countryCodeKey] as? String, let locality = dictionary[Recipe.localityKey] as? String {
                dictionaryToUpload[Recipe.countryCodeKey] = countryCode
                dictionaryToUpload[Recipe.localityKey] = locality
                dictionaryToUpload[Recipe.countryKey] = dictionary[Recipe.countryKey]
                dictionaryToUpload["longitude"] = dictionary["longitude"]
                dictionaryToUpload["latitude"] = dictionary["latitude"]
                
                self.ref.child("localities").updateChildValues([locality: true])
                self.ref.child("locations").child(dictionary[Recipe.countryKey] as! String).updateChildValues(["countryCode": countryCode])
                self.ref.child("locations").child(dictionary[Recipe.countryKey] as! String).child("recipes").child(recipeID).setValue(true)
            }
            
            self.ref.child("recipes").child(recipeID).updateChildValues(dictionaryToUpload)
            
            self.ref.child("users").child(currentUser.uid).child("uploadedRecipes").child(recipeID).setValue(true)
            
            NotificationCenter.default.post(Notification(name: Notification.Name("RecipeUploaded")))
            
            if uid == nil {
                Analytics.logEvent("recipe_uploaded", parameters: ["username": Auth.auth().currentUser!.displayName!, "userID": Auth.auth().currentUser!.uid])
                
                let uploadedRecipeEvent = AppEvent(name: "uploaded-recipe", parameters: ["userID": Auth.auth().currentUser!.uid], valueToSum: 1)
                AppEventsLogger.log(uploadedRecipeEvent)
            }
            
//            if let firstRecipeUploaded = UserDefaults.standard.object(forKey: "firstRecipeUploaded") as? Bool {
//                print("First recipe has already been uploaded: \(firstRecipeUploaded)")
//
//                let string = uid == nil ? "Recipe uploaded" : "Recipe updated"
//                SVProgressHUD.showSuccess(withStatus: string)
//                SVProgressHUD.dismiss(withDelay: 0.5)
//            }
            
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
