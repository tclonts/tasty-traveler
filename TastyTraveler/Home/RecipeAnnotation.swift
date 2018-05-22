//
//  RecipeAnnotation.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/9/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import Foundation
import MapKit

class RecipeAnnotation: NSObject, MKAnnotation {
    var recipe: Recipe
    var coordinate: CLLocationCoordinate2D { return recipe.coordinate! }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        super.init()
    }
}
