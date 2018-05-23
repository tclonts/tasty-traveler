//
//  RecipeAnnotationView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/9/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import MapKit
import Cosmos
import Stevia

class RecipeAnnotationView: MKAnnotationView {
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.sv(recipeImageView)
        
        recipeImageView.height(40).width(40).centerInContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if (hitView != nil)
        {
            self.superview?.bringSubview(toFront: self)
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if(!isInside)
        {
            for view in self.subviews
            {
                isInside = view.frame.contains(point)
                if isInside
                {
                    break
                }
            }
        }
        return isInside
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            
            canShowCallout = false
            
            guard let recipeAnnotation = newValue as? RecipeAnnotation else { return }
            
            let urlString = recipeAnnotation.recipe.photoURL
            
            if let cachedImage = imageCache[urlString] {
                
                self.recipeImageView.image = cachedImage
                return
            }
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Failed to fetch image: ", error)
                    return
                }
                
                guard let imageData = data else { return }
                
                let photoImage = UIImage(data: imageData)
                
                imageCache[url.absoluteString] = photoImage
                
                DispatchQueue.main.async {
                    
                    self.recipeImageView.image = photoImage
                }
            }.resume()
        }
    }
}

class RecipeCalloutView: UIView {
    var recipe: Recipe!
    weak var delegate: RecipeCalloutViewDelegate?

    let recipePhoto: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let recipeNameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.bold.of(size: 12)
        label.textColor = Color.darkText
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    let starsRatingView: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .precise
        cosmosView.settings.starSize = Double(adaptConstant(10))
        cosmosView.settings.starMargin = Double(adaptConstant(2))
        cosmosView.settings.filledColor = Color.primaryOrange
        cosmosView.settings.emptyBorderColor = Color.primaryOrange
        cosmosView.settings.filledBorderColor = Color.primaryOrange
        cosmosView.settings.textFont = ProximaNova.regular.of(size: 11)
        return cosmosView
    }()

//    lazy var viewRecipeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("View Recipe", for: .normal)
//        button.setTitleColor(Color.gray, for: .normal)
//        button.layer.borderColor = Color.gray.cgColor
//        button.layer.cornerRadius = adaptConstant(3)
//        button.layer.borderWidth = 1
//        button.titleLabel?.font = ProximaNova.regular.of(size: 10)
//        button.addTarget(self, action: #selector(viewRecipeTapped), for: .touchUpInside)
//        return button
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewRecipeTapped)))

        backgroundColor = .white
        layer.cornerRadius = adaptConstant(10)
        layer.masksToBounds = true
        clipsToBounds = true

        self.height(adaptConstant(80)).width(adaptConstant(240))

        sv(recipePhoto, recipeNameLabel, starsRatingView)
        
        recipePhoto.left(0).top(0).bottom(0)
        recipePhoto.width(adaptConstant(120))
        
        recipeNameLabel.top(8).right(8)
        recipeNameLabel.Left == recipePhoto.Right + 8
        starsRatingView.Top == recipeNameLabel.Bottom + 8
        starsRatingView.Left == recipePhoto.Right + 8
//        viewRecipeButton.bottom(8).right(8).width(adaptConstant(70)).height(adaptConstant(15))
    }

    @objc func viewRecipeTapped() {
        delegate?.recipeDetailView(recipe: recipe)
    }

    func configureWithRecipe(recipe: Recipe) {
        self.recipe = recipe
        self.recipePhoto.loadImage(urlString: recipe.photoURL, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
        self.recipeNameLabel.text = recipe.name

        recipe.averageRating { (rating) in
            self.starsRatingView.rating = rating
            self.starsRatingView.text = "(\(recipe.reviewsDictionary?.count ?? 0))"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol RecipeCalloutViewDelegate: class {
    func recipeDetailView(recipe: Recipe)
}

