//
//  ExtensionsForPointSystem.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 8/22/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase


extension RecipeDetailVC {
    
    func pointAdder(numberOfPoints: Int) {
        
        guard let recipeUID = recipe?.uid else { return }
        
        FirebaseController.shared.fetchRecipeWithUID(uid: recipeUID) { (recipe) in
            guard let recipe = recipe else { return }
            let cook = recipe.creator
            var points = recipe.creator.points
            let newPoints = points! + numberOfPoints
            FirebaseController.shared.ref.child("users").child((cook.uid)).child("points").setValue(newPoints)

//            if points != nil {
//                FirebaseController.shared.ref.child("users").child((cook.uid)).child("points").setValue(points! + numberOfPoints)
//            } else {
//                FirebaseController.shared.ref.child("users").child((cook.uid)).child("points").setValue(8)
//            }
        }
    }
    
    func pointAdderForAppReview(numberOfPoints: Int) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            var points = user.points
            
            if points != nil {
                FirebaseController.shared.ref.child("users").child((user.uid)).child("points").setValue(points! + numberOfPoints)
            } else {
                FirebaseController.shared.ref.child("users").child((user.uid)).child("points").setValue(8)
            }
        }
        
    }
    
    
}
