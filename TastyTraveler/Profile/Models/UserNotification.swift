//
//  UserNotification.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/21/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct UserNotification {
    
    // Avatar - Username - Text - recipeID - Photo
    //         michael  cooked your  recipe
    // Avatar - Username - text
    //         michael  sent you a message!
    var uid: String
    var user: TTUser
    var type: UserNotificationType
    var message: String
    var recipeID: String?
    var photoURL: String?
    var creationDate: Date
    
    init(uid: String, user: TTUser, dictionary: [String:Any]) {
        self.uid = uid
        self.user = user
        self.message = dictionary["message"] as! String
        let typeText = dictionary["type"] as! String
        self.type = UserNotificationType(rawValue: typeText)!
        self.recipeID = dictionary["recipeID"] as? String
        self.photoURL = dictionary["photoURL"] as? String
        let timestamp = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: timestamp)
    }
}

enum UserNotificationType: String {
    case favorited
    case cooked
}

