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
            let newPoints = points != nil ? points! + numberOfPoints : numberOfPoints
            FirebaseController.shared.ref.child("users").child((cook.uid)).child("points").setValue(newPoints)
        }
    }
    
    func pointAdderForCurrentUserID(numberOfPoints: Int) {

        guard let userID = Auth.auth().currentUser?.uid else { return }
        FirebaseController.shared.fetchUserWithUID(uid: userID) { (user) in
            guard let user = user else { return }
            var points = user.points
            let newPoints = points != nil ? points! + numberOfPoints : numberOfPoints
            FirebaseController.shared.ref.child("users").child(userID).child("points").setValue(newPoints)
        }

    }
}
