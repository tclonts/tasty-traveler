//
//  Question.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

struct Question {
    var uid: String
    var recipeID: String
    var askerID: String
    var receiverID: String
    
    var user: User?
    var lastMessage: Message?
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.recipeID = dictionary["recipeID"] as! String
        self.askerID = dictionary["askerID"] as! String
        self.receiverID = dictionary["receiverID"] as! String
    }
}
