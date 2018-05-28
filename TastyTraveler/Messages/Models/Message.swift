//
//  Message.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import FirebaseAuth

struct Message {
    var fromID: String
    var toID: String
    var timestamp: Date
    var text: String
    var recipeID: String
    var uid: String
    
    var isUnread = true
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.fromID = dictionary["fromID"] as! String
        self.toID = dictionary["toID"] as! String
        let timeInterval = dictionary["timestamp"] as! Double
        self.timestamp = Date(timeIntervalSince1970: timeInterval)
        self.text = dictionary["text"] as! String
        self.recipeID = dictionary["recipeID"] as! String
        self.isUnread = dictionary["unread"] as! Bool
    }
    
    func chatPartnerID() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
}
