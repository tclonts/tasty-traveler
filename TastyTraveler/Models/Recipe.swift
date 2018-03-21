//
//  Recipe.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/19/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct Recipe {
    var uid: String?
    
    var city: String?
    var country: String?
    var countryCode: String?
    
    var name: String
    var creator: User
    var timestamp: Double
    
    var overallRating: Double?
    var ratings: [Int]?
    
    var description: String?
    var servings: Int
    var timeInMinutes: Int
    var ingredients: [String]
    var steps: [String]
    
    var videoURL: String?
    var photoURL: String
    
    var tags: [Tag]?
    
    var hasFavorited = false
    var hasCooked = false
    
    init(creator: User, dictionary: [String:Any]) {
        self.creator = creator
        self.country = dictionary["country"] as? String
        self.countryCode = dictionary["countryCode"] as? String
        self.name = dictionary["name"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Double ?? 0
        self.ratings = dictionary["ratings"] as? [Int]
        
        if let ratings = self.ratings {
            self.overallRating = averageRating(ratings)
        }
        
        self.description = dictionary["description"] as? String
        self.servings = dictionary["servings"] as? Int ?? 0
        self.timeInMinutes = dictionary["timeInMinutes"] as? Int ?? 0
        self.ingredients = dictionary["ingredients"] as? [String] ?? [String]()
        self.steps = dictionary["steps"] as? [String] ?? [String]()
        self.videoURL = dictionary["videoURL"] as? String
        self.photoURL = dictionary["photoURL"] as? String ?? ""
        if let tags = dictionary["tags"] as? [String] {
            self.tags = tags.map { return Tag(rawValue: $0)! }
        }
    }
}

func averageRating(_ ratings: [Int]) -> Double {
    let sumRatings = ratings.reduce(0, +)
    let averageValue = Double(sumRatings) / Double(ratings.count)
    //let roundedValue = averageValue.round(nearest: 0.1)
    return averageValue
}

enum Tag: String {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-free"
    case whole30 = "Whole 30"
    case budget = "Budget"
    case paleo = "Paleo"
    case organic = "Organic"
}
