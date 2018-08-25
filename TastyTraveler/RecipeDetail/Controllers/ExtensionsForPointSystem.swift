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
}
