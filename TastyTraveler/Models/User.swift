//
//  User.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/6/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct TTUser {
    var uid: String
    var avatarURL: String?
//    var country: String?
    var username: String
    var bio: String?
    var points: Int = 0
    var badgeStatus: Int = 1
    
    
//    var cookedRecipes: [String]?   // recipe IDs
//    var favoriteRecipes: [String]? // recipe IDs
//    var uploadedRecipes: [String]? // recipe IDs
//    var ratedRecipes: [String]?    // recipe IDs
//    var conversations: [String]?   // conversation IDs
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.avatarURL = dictionary["avatarURL"] as? String
        self.bio = dictionary["bio"] as? String
    }
}
