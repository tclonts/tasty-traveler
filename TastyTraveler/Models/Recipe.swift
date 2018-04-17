//
//  Recipe.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/19/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation

struct Recipe {
    // KEYS
    static let uidKey = "uid"
    static let cityKey = "city"
    static let countryKey = "country"
    static let countryCodeKey = "countryCode"
    static let nameKey = "name"
    static let creatorKey = "creator"
    static let creatorIDKey = "creatorID"
    static let creationDateKey = "creationDate"
    static let overallRatingKey = "overallRating"
    static let ratingsKey = "ratings"
    static let descriptionKey = "description"
    static let servingsKey = "servings"
    static let timeInMinutesKey = "timeInMinutes"
    static let difficultyKey = "difficulty"
    static let ingredientsKey = "ingredients"
    static let stepsKey = "steps"
    static let videoURLKey = "videoURL"
    static let photoKey = "photo"
    static let photoURLKey = "photoURL"
    static let thumbnailURLKey = "thumbnailURL"
    static let tagsKey = "tags"
    static let hasFavoritedKey = "hasFavorited"
    static let hasCookedKey = "hasCooked"
    
    var uid: String?
    
    var city: String?
    var country: String?
    var countryCode: String?
    
    var name: String
    var creator: User
    var creationDate: Date
    
    var overallRating: Double?
    var ratings: [Int]?
    
    var description: String?
    var servings: Int
    var timeInMinutes: Int
    var difficulty: String
    var ingredients: [String]
    var steps: [String]
    
    var videoURL: String?
    var photoURL: String
    var thumbnailURL: String?
    
    var tags: [Tag]?
    
    var hasFavorited = false
    var hasCooked = false
    
    init(creator: User, dictionary: [String:Any]) {
        self.creator = creator
        self.country = dictionary[Recipe.countryKey] as? String
        self.countryCode = dictionary[Recipe.countryCodeKey] as? String
        self.name = dictionary[Recipe.nameKey] as? String ?? ""
        let timestamp = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: timestamp)
        self.ratings = dictionary[Recipe.ratingsKey] as? [Int]
        self.difficulty = dictionary[Recipe.difficultyKey] as? String ?? "Easy"
        
        if let ratings = self.ratings {
            self.overallRating = averageRating(ratings)
        }
        
        self.description = dictionary[Recipe.descriptionKey] as? String
        self.servings = dictionary[Recipe.servingsKey] as? Int ?? 0
        self.timeInMinutes = dictionary[Recipe.timeInMinutesKey] as? Int ?? 0
        self.ingredients = dictionary[Recipe.ingredientsKey] as? [String] ?? [String]()
        self.steps = dictionary[Recipe.stepsKey] as? [String] ?? [String]()
        self.videoURL = dictionary[Recipe.videoURLKey] as? String
        self.thumbnailURL = dictionary[Recipe.thumbnailURLKey] as? String
        self.photoURL = dictionary[Recipe.photoURLKey] as? String ?? ""
        if let tags = dictionary[Recipe.tagsKey] as? [String] {
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
