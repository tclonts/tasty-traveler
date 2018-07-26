//
//  RecipesMapView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/9/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import MapKit
import Stevia
import FirebaseAuth

class RecipesMapView: UIViewController, MKMapViewDelegate, RecipeCalloutViewDelegate {
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let navigationBarBackground: GradientView = {
        let gradientView = GradientView()
        gradientView.startPointX = 0.5
        gradientView.startPointY = 0
        gradientView.endPointX = 0.5
        gradientView.endPointY = 1
        gradientView.topColor = UIColor.black.withAlphaComponent(0.64)
        gradientView.bottomColor = UIColor.black.withAlphaComponent(0)
        return gradientView
    }()
    
    let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    var mapView = MKMapView()
    var annotations = [RecipeAnnotation]()
    var selectedRecipe: Recipe?
    var filteredRecipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.lightGray
        mapView.delegate = self
        mapView.register(RecipeAnnotationView.self, forAnnotationViewWithReuseIdentifier: "recipeAnnotation")
        
        setUpViews()
        
        fetchAnnotations()
        
        let viewContentEvent = AppEvent.viewedContent(contentType: "interactive-map", contentId: nil, currency: nil, valueToSum: 1.0, extraParameters: nil)
        AppEventsLogger.log(viewContentEvent)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpViews() {
        view.sv(mapView, navigationBarBackground, navigationBar.sv(backButton))
        
        navigationBarBackground.Top == self.view.Top
        navigationBarBackground.Bottom == navigationBar.Bottom
        navigationBarBackground.Left == self.view.Left
        navigationBarBackground.Right == self.view.Right
        
        navigationBar.Top == view.safeAreaLayoutGuide.Top
        navigationBar.Left == view.safeAreaLayoutGuide.Left
        navigationBar.Right == view.safeAreaLayoutGuide.Right
        navigationBar.height(44)
        
        backButton.left(adaptConstant(20)).centerVertically()
        
        mapView.fillContainer()
    }
    
    func fetchAnnotations() {
        // Fetch list of localities
        // for each locality > query top 25 recipes with locality == locality, sorted by recipeScore > for each recipe > create annotation using recipe
//        if filteredRecipes.isEmpty {
//            FirebaseController.shared.ref.child("localities").observeSingleEvent(of: .value) { (snapshot) in
//                guard let localities = snapshot.value as? [String:Any] else { return }
//                
//                localities.keys.forEach { locality in
//                    let localityQuery = FirebaseController.shared.ref.child("recipes").queryOrdered(byChild: "locality").queryEqual(toValue: locality)
//                    localityQuery.observeSingleEvent(of: .value, with: { (snapshot) in
//                        guard let recipesInLocality = snapshot.value as? [String:Any] else { return }
//                        print(recipesInLocality)
//                        
//                        var topRecipes = [Recipe]()
//                        let lastCount = recipesInLocality.count // 3   1
//                        var count = 0
//                        recipesInLocality.forEach({ (key, value) in
//                            guard let recipeDictionary = value as? [String:Any] else { return }
//                            guard let creatorID = recipeDictionary[Recipe.creatorIDKey] as? String else { return }
//                            
//                            FirebaseController.shared.fetchUserWithUID(uid: creatorID, completion: { (creator) in
//                                guard let creator = creator else { count += 1; return }
//                                count += 1
//                                var recipe = Recipe(uid: key, creator: creator, dictionary: recipeDictionary)
//                                
//                                if recipe.coordinate == nil {
//                                    return
//                                }
//                                
//                                guard let userID = Auth.auth().currentUser?.uid else { return }
//                                FirebaseController.shared.ref.child("users").child(userID).child("favorites").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
//                                    if (snapshot.value as? Double) != nil {
//                                        recipe.hasFavorited = true
//                                    } else {
//                                        recipe.hasFavorited = false
//                                    }
//                                    
//                                    FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
//                                        if (snapshot.value as? Double) != nil {
//                                            recipe.hasCooked = true
//                                            let timestamp = (snapshot.value as! Double)
//                                            recipe.cookedDate = Date(timeIntervalSince1970: timestamp)
//                                        } else {
//                                            recipe.hasCooked = false
//                                        }
//                                        
//                                    
//                                        topRecipes.append(recipe)
//                                    
//                                        if count == lastCount {
//                                            topRecipes.sort(by: { (r1, r2) -> Bool in
//                                                return r1.recipeScore > r2.recipeScore
//                                            })
//                                        
//                                            let top25 = Array(topRecipes.prefix(3))
//                                            top25.forEach({ (recipe) in
//                                                self.mapView.addAnnotation(RecipeAnnotation(recipe: recipe))
//                                            })
//                                        }
//                                    
//                                    })
//                                }, withCancel: { (error) in
//                                    print("Failed to fetch favorite info for recipe: ", error)
//                                })
//                            })
//                        })
//                    })
//                }
//            }
//        } else {
            filteredRecipes.forEach({ (recipe) in
                if recipe.coordinate != nil {
                    self.mapView.addAnnotation(RecipeAnnotation(recipe: recipe))
                }
            })
//        }
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "recipeAnnotation")
        
        if annotationView == nil {
            annotationView = RecipeAnnotationView(annotation: annotation, reuseIdentifier: "recipeAnnotation")
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let recipeAnnotation = view.annotation as! RecipeAnnotation
        let calloutView = RecipeCalloutView()
        calloutView.configureWithRecipe(recipe: recipeAnnotation.recipe)
        calloutView.delegate = self
        view.sv(calloutView)
        calloutView.centerHorizontally()
        calloutView.Bottom == view.Top - 20
        mapView.setCenter(view.annotation!.coordinate, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: RecipeAnnotationView.self) {
            for subview in view.subviews {
                if subview.isKind(of: RecipeCalloutView.self) { subview.removeFromSuperview() }
            }
        }
    }
    
    func recipeDetailView(recipe: Recipe) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let recipeDetailVC = RecipeDetailVC()
        recipeDetailVC.recipe = recipe
        if recipe.creator.uid == userID { recipeDetailVC.isMyRecipe = true }
        recipeDetailVC.isFromFavorites = true
        //recipeDetailVC.formatCookButton()
        recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: recipe.photoURL, placeholder: nil)
        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
        recipeNavigationController.navigationBar.isHidden = true
        
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
}
