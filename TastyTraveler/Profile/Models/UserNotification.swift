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
    
    var user: TTUser
    var text: String
    var recipeID: String?
    var photoURL: String?
    var creationDate: Date
    
}
