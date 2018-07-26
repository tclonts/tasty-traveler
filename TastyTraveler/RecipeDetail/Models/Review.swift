//
//  Review.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/7/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct Review {
    var uid: String!
    var title: String?
    var text: String?
    var rating: Int?
    var user: TTUser!
    var reviewerID: String
    var recipeID: String
    var creationDate: Date!
    var commentsDictionary: [String:String]?
    var upvotes = 0
    
    init(uid: String, dictionary: [String:Any]) {
        self.uid = uid
        self.title = dictionary["title"] as? String
        if let timestamp = dictionary["timestamp"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: timestamp)
        }
        self.commentsDictionary = dictionary["comments"] as? [String:String]
        self.upvotes = dictionary["upvotes"] as? Int ?? 0
        self.text = dictionary["text"] as? String
        self.rating = dictionary["rating"] as? Int
        self.reviewerID = dictionary["reviewerID"] as! String
        self.recipeID = dictionary["recipeID"] as! String
    }
}
