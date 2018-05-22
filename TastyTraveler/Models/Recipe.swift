//
//  Recipe.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/19/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

struct Recipe {
    // KEYS
    static let uidKey = "uid"
    static let mealKey = "meal"
    static let localityKey = "locality"
    static let countryCodeKey = "countryCode"
    static let countryKey = "country"
    static let nameKey = "name"
    static let creatorKey = "creator"
    static let creatorIDKey = "creatorID"
    static let creationDateKey = "creationDate"
    static let overallRatingKey = "overallRating"
    static let ratingsKey = "ratings"
    static let reviewIDsKey = "reviewIDs"
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
    
    var uid: String
    
    var meal: String?
    
    var locality: String?
    var countryCode: String?
    var country: String?
    var coordinate: CLLocationCoordinate2D?
    
    var name: String
    var creator: TTUser
    var creationDate: Date
    
    var reviewsDictionary: [String:String]?
    var recipeScore: Double = 0
    var averageRating: Double?
    
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
    
    // PERSONAL
    var hasFavorited = false
    var favoritedDate: Date?
    var hasCooked = false
    var cookedDate: Date?
    
    init(uid: String, creator: TTUser, dictionary: [String:Any]) {
        self.uid = uid
        self.creator = creator
        self.meal = dictionary[Recipe.mealKey] as? String
        self.locality = dictionary[Recipe.localityKey] as? String
        self.countryCode = dictionary[Recipe.countryCodeKey] as? String
        self.country = dictionary[Recipe.countryKey] as? String
        
        if let longitude = dictionary["longitude"] as? Double, let latitude = dictionary["latitude"] as? Double {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        self.name = dictionary[Recipe.nameKey] as? String ?? ""
        
        let timestamp = dictionary["timestamp"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: timestamp)
        
        if let reviewIDsDict = dictionary["reviews"] as? [String:String] {
            self.reviewsDictionary = reviewIDsDict
        }
        
        self.difficulty = dictionary[Recipe.difficultyKey] as? String ?? "Easy"
        
//        if let ratings = self.ratings {
//            self.overallRating = averageRating(ratings)
//        }
        self.recipeScore = dictionary["recipeScore"] as? Double ?? 0
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
    
    func averageRating(completion: @escaping (Double) -> ()) {
        
        var reviews = [Review]()
        
        guard let reviewIDsValues = self.reviewsDictionary?.values else { completion(0.0); return }
        
        let reviewIDs = Array(reviewIDsValues)
        
        let lastReviewID = reviewIDs.last!
        
        reviewIDs.forEach({ (reviewID) in
            FirebaseController.shared.ref.child("reviews").child(reviewID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let reviewDictionary = snapshot.value as? [String:Any] else { return }
                
                reviews.append(Review(uid: reviewID, dictionary: reviewDictionary))
                
                if reviewID == lastReviewID {
                    let ratings = reviews.flatMap { $0.rating }
                    let sumOfRatings = ratings.reduce(0, +)
                    // average = sumOfRatings / ratings.count
                    completion(Double(sumOfRatings) / Double(ratings.count))
                }
            })
        })
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
