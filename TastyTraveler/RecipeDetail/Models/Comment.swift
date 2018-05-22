//
//  Comment.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct Comment {
    var uid: String
    var text: String
    var creationDate: Date
    var user: TTUser?
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.text = dictionary["text"] as! String
        let timestamp = dictionary["timestamp"] as! Double
        self.creationDate = Date(timeIntervalSince1970: timestamp)
    }
}
