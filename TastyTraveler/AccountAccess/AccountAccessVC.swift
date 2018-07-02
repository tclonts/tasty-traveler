//
//  AccountAccessVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/6/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Hero
import FacebookCore
import FacebookLogin
import Firebase
import SVProgressHUD
import ws
import Arrow
import CoreLocation

class AccountAccessVC: UIViewController {

    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backgroundImage")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "tasty traveler"
        label.textColor = UIColor.white
        label.heroModifiers = [.fade, .translate(y: -200)]
        return label
    }()
    
//    lazy var onboardingCollectionVC: OnboardingCollectionVC = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        let vc = OnboardingCollectionVC(collectionViewLayout: layout)
//        addChildViewController(vc)
//        vc.didMove(toParentViewController: self)
//        return vc
//    }()
    
//    let pageControl: UIPageControl = {
//        let pageControl = UIPageControl()
//        pageControl.numberOfPages = 3
//        pageControl.isUserInteractionEnabled = false
//        return pageControl
//    }()
    
    let onboardingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let earthImageView = UIImageView(image: #imageLiteral(resourceName: "earth"))
        earthImageView.height(adaptConstant(183)).width(adaptConstant(183))
        
        let circleImageView = UIImageView(image: #imageLiteral(resourceName: "circle"))
        circleImageView.height(adaptConstant(217)).width(adaptConstant(217))
        
        let magnifyingGlassImageView = UIImageView(image: #imageLiteral(resourceName: "magnifyingGlass"))
        magnifyingGlassImageView.height(adaptConstant(119)).width(adaptConstant(121))
        
        let label = UILabel()
        label.text = "Discover authentic recipes from around the world."
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(20))
        label.alpha = 0.85
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        view.sv(earthImageView, circleImageView, magnifyingGlassImageView, label)
        
        earthImageView.top(adaptConstant(18))
        earthImageView.centerHorizontally()
        
        circleImageView.top(0)
        circleImageView.centerHorizontally()
        
        magnifyingGlassImageView.Bottom == earthImageView.Bottom
        magnifyingGlassImageView.Left == circleImageView.CenterX
        
        label.Top == circleImageView.Bottom + adaptConstant(40)
        label.left(0).right(0).bottom(0)
        label.centerHorizontally()
        
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = adaptConstant(17)
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let shadowView = UIView()
        //shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 10
        
        shadowView.sv(view)
        view.followEdges(shadowView)
        shadowView.heroModifiers = [.fade, .translate(y: 200)]
        
        return shadowView
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = adaptConstant(17)
        view.layer.masksToBounds = true
        
        let shadowView = UIView()
        //shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 10
        
        shadowView.sv(view)
        view.followEdges(shadowView)
        shadowView.alpha = 0
        shadowView.heroID = "cardView"
        return shadowView
    }()
    
    lazy var emailSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "signUpButton"), for: .normal)
        button.addTarget(self, action: #selector(emailSignUpButtonTapped), for: .touchUpInside)
        let icon = UIImageView(image: #imageLiteral(resourceName: "emailIcon"))
        icon.width(adaptConstant(14))
        icon.height(adaptConstant(11))
        
        let label = UILabel()
        label.text = "SIGN UP"
        let fontSize = adaptConstant(14)
        label.font = UIFont(name: "ProximaNova-SemiBold", size: fontSize)
        label.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        button.sv(stackView)
        stackView.centerInContainer()
        return button
    }()
    
    lazy var facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "facebookButton"), for: .normal)
        let icon = UIImageView(image: #imageLiteral(resourceName: "facebookIcon"))
        icon.width(adaptConstant(14))
        icon.height(adaptConstant(15))
        button.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        let label = UILabel()
        label.text = "CONNECT"
        let fontSize = adaptConstant(14)
        label.font = UIFont(name: "ProximaNova-SemiBold", size: fontSize)
        label.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        button.sv(stackView)
        stackView.centerInContainer()
        return button
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitleString = NSString(string: "Already have an account?  Sign In")
        let range = buttonTitleString.range(of: "Sign In")
        let fontSize = adaptConstant(16)
        let attributedString = NSMutableAttributedString(string: buttonTitleString as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-Regular", size: fontSize)!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor(hexString: "6d6d6d")])
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont(name: "ProximaNova-Bold", size: fontSize)!,
                                        NSAttributedStringKey.foregroundColor : UIColor(hexString: "6d6d6d")], range: range)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func setUpViews() {
        
        
        let stackView = UIStackView(arrangedSubviews: [emailSignUpButton, facebookButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        self.view.sv(
            backgroundView,
            titleLabel,
            //onboardingCollectionVC.view,
            //pageControl,
            onboardingView,
            cardView,
            bottomView.sv(
                stackView,
                signInButton
            )
        )
        
        backgroundView.fillContainer()
        
        // Title label
        let fontSize = adaptConstant(45)
//        let spacing = adaptConstant(38)
        titleLabel.font = UIFont(name: "ProximaNova-Bold", size: fontSize)
        titleLabel.Bottom == onboardingView.Top - adaptConstant(40)
        titleLabel.centerHorizontally()
        
        // Onboarding Collection View
//        onboardingCollectionVC.accountAccessVC = self
//        onboardingCollectionVC.view.backgroundColor = .clear
//        onboardingCollectionVC.collectionView?.backgroundColor = .clear
//        onboardingCollectionVC.view.Top == titleLabel.Bottom + adaptConstant(34)
//        onboardingCollectionVC.view.fillHorizontally()
//        onboardingCollectionVC.view.Bottom == bottomView.Top
//        pageControl.Bottom == onboardingCollectionVC.view.Bottom - spacing
//        pageControl.centerHorizontally()
        if screenHeight == iPhoneXScreenHeight {
            onboardingView.centerInContainer()
        } else {
            onboardingView.Bottom == bottomView.Top - adaptConstant(60)
        }
        onboardingView.left(adaptConstant(60)).right(adaptConstant(60))
        
        // Bottom View
        var bottomHeight = adaptConstant(146)
        if screenHeight == iPhoneXScreenHeight { bottomHeight += self.view.safeAreaInsets.bottom + 12 }
        bottomView.height(bottomHeight)
        bottomView.left(adaptConstant(20))
        bottomView.right(adaptConstant(20))
        bottomView.bottom(0)
        
        cardView.followEdges(bottomView)
        
        // Email Sign Up Button
        equal(widths: emailSignUpButton, facebookButton)
        stackView.top(adaptConstant(38))
        stackView.left(adaptConstant(20))
        stackView.right(adaptConstant(20))
        stackView.height(adaptConstant(50))
        stackView.centerHorizontally()
        
        signInButton.centerHorizontally()
        if screenHeight == iPhoneXScreenHeight {
            signInButton.Top == stackView.Bottom + 12
        } else {
            signInButton.Top == stackView.Bottom
            signInButton.bottom(0)
        }
    }
    
    @objc func signInButtonTapped() {
        let signInVC = SignInVC()
        signInVC.isHeroEnabled = true
        signInVC.view.heroModifiers = [.fade]
        self.present(signInVC, animated: true, completion: nil)
    }
    
    @objc func emailSignUpButtonTapped() {
        let signUpVC = SignUpVC()
        signUpVC.isHeroEnabled = true
        signUpVC.view.heroModifiers = [.fade]
        self.present(signUpVC, animated: true, completion: nil)

        //retrieveRecipes()
        //createUsers()
    }
    
    var cuisineLocations = ["chinese": [CLLocationCoordinate2D(latitude: 31.228611, longitude: 121.474722),
                                        CLLocationCoordinate2D(latitude: 39.916667, longitude: 116.383333),
                                        CLLocationCoordinate2D(latitude: 23.133333, longitude: 113.266667)],
                            "indian": [CLLocationCoordinate2D(latitude: 18.975, longitude: 72.825833),
                                       CLLocationCoordinate2D(latitude: 28.61, longitude: 77.23),
                                       CLLocationCoordinate2D(latitude: 12.983333, longitude: 77.583333)],
                            "british": [CLLocationCoordinate2D(latitude: 52.483056, longitude: -1.893611),
                                        CLLocationCoordinate2D(latitude: 53.383611, longitude: -1.466944),
                                        CLLocationCoordinate2D(latitude: 53.479444, longitude: -2.245278)],
                            "irish": [CLLocationCoordinate2D(latitude: 53.349722, longitude: -6.260278),
                                      CLLocationCoordinate2D(latitude: 51.897222, longitude: -8.47),
                                      CLLocationCoordinate2D(latitude: 53.271944, longitude: -9.048889)],
                            "french": [CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508),
                                       CLLocationCoordinate2D(latitude: 43.2964, longitude: 5.37),
                                       CLLocationCoordinate2D(latitude: 45.76, longitude: 4.84)],
                            "italian": [CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5),
                                        CLLocationCoordinate2D(latitude: 45.466667, longitude: 9.183333),
                                        CLLocationCoordinate2D(latitude: 40.833333, longitude: 14.25)],
                            "mexican": [CLLocationCoordinate2D(latitude: 19.433333, longitude: -99.133333),
                                        CLLocationCoordinate2D(latitude: 19.609722, longitude: -99.06),
                                        CLLocationCoordinate2D(latitude: 20.666667, longitude: -103.35)],
                            "jewish": [CLLocationCoordinate2D(latitude: 31.783333, longitude: 35.216667),
                                       CLLocationCoordinate2D(latitude: 32.066667, longitude: 34.783333),
                                       CLLocationCoordinate2D(latitude: 32.816667, longitude: 34.983333)],
//                            "american": [CLLocationCoordinate2D(latitude: 34.05, longitude: -118.25),
//                                         CLLocationCoordinate2D(latitude: 29.762778, longitude: -95.383056),
//                                         CLLocationCoordinate2D(latitude: 30.336944, longitude: -81.661389),
//                                         CLLocationCoordinate2D(latitude: 40.7127, longitude: -74.0059),
//                                         CLLocationCoordinate2D(latitude: 40.009376, longitude: -75.133346)],
                            "greek": [CLLocationCoordinate2D(latitude: 37.983972, longitude: 23.727806),
                                      CLLocationCoordinate2D(latitude: 40.65, longitude: 22.9),
                                      CLLocationCoordinate2D(latitude: 38.25, longitude: 21.733333)],
                            "german": [CLLocationCoordinate2D(latitude: 52.516667, longitude: 13.388889),
                                       CLLocationCoordinate2D(latitude: 53.565278, longitude: 10.001389),
                                       CLLocationCoordinate2D(latitude: 48.133333, longitude: 11.566667)],
                            "nordic": [CLLocationCoordinate2D(latitude: 59.329444, longitude: 18.068611),  // sweden - 633830, 658970, 535892, 195336
                                       CLLocationCoordinate2D(latitude: 59.916667, longitude: 10.733333)], // norway - 660225, 648980, 551392, 447965
                            ]
    
    
    
    func retrieveRecipes() {

        let meals = ["breakfast", "snack", "drink", "dinner", "lunch", "dessert"]
        let defaultURL = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes"
        let ws = WS(defaultURL)
        ws.headers = ["X-Mashape-Key": "YOwj5Zy0PamshJakYxjZmpWUeh3Ep1a97grjsnC8615NGeTqBH", "Accept": "application/json"]

        let numberOfRecipes = 50
        let cuisine = "german"
        
//        for cuisine in cuisineLocations.keys {
        
            ws.get("/random", params: ["limitLicense": false, "number": numberOfRecipes, "tags": cuisine]).then { (json: JSON) in
                
                guard let recipesDict = json.data as? [String:Any] else { return }
                
                for recipeD in recipesDict {
                    
                    if let recipearr = recipeD.value as? Array<Any> {
                        
                        for recipe in recipearr {
                            
                            let randomNameIndex = Int(arc4random_uniform(UInt32(self.randomNames.count)))
                            let name = self.randomNames[randomNameIndex]
                            
                            guard let coordinates = self.cuisineLocations[cuisine] else { return }
                            let randomIndex = Int(arc4random_uniform(UInt32(coordinates.count)))
                            let randomCoordinate = coordinates[randomIndex]
                            let latitude = randomCoordinate.latitude
                            let longitude = randomCoordinate.longitude
                            
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            let geocoder = CLGeocoder()
                            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                                if error == nil {
                                    guard let placemark = placemarks?[0] else { print("placemark not found"); return }
                                    let countryCode = placemark.isoCountryCode
                                    let country = placemark.country
                                    let locality = placemark.locality
                                    
                                    var recipeName: String
                                    var steps = [String]()
                                    var ingredients = [String]()
                                    var photoURL: String
                                    var mealtype: String
                                    var servings: Int
                                    var timeInMinutes: Int
                                    let difficulty = "Medium"
                                    var tags = [String]()
                                    
                                    if let recipedict = recipe as? [String:Any] {
                                        // STEPS
                                        if let instructionsArray = recipedict["analyzedInstructions"] as? Array<Any> {
                                            for instruction in instructionsArray {
                                                if let instructionsDict = instruction as? [String:Any] {
                                                    if let sectionName = instructionsDict["name"] as? String, sectionName != "" {
                                                        steps.append(sectionName)
                                                    }
                                                    
                                                    if let stepsArray = instructionsDict["steps"] as? Array<Any> {
                                                        for step in stepsArray {
                                                            if let stepText = (step as! [String:Any])["step"] as? String {
                                                                steps.append(stepText)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else { return }
                                        
                                        // INGREDIENTS
                                        if let ingredientsArray = recipedict["extendedIngredients"] as? Array<Any> {
                                            for ingredient in ingredientsArray {
                                                if let ingredientsDict = ingredient as? [String:Any] {
                                                    if let ingredientText = ingredientsDict["original"] as? String {
                                                        ingredients.append(ingredientText)
                                                    }
                                                }
                                            }
                                        } else { return }
                                        
                                        // TAGS
                                        if let whole30 = recipedict["whole30"] as? Int, whole30 == 1 { tags.append(Tag.whole30.rawValue) }
                                        if let vegetarian = recipedict["vegetarian"] as? Int, vegetarian == 1 { tags.append(Tag.vegetarian.rawValue) }
                                        if let vegan = recipedict["vegan"] as? Int, vegan == 1 { tags.append(Tag.vegan.rawValue) }
                                        if let glutenFree = recipedict["glutenFree"] as? Int, glutenFree == 1 { tags.append(Tag.glutenFree.rawValue) }
                                        if let dairyFree = recipedict["dairyFree"] as? Int, dairyFree == 1 { tags.append(Tag.dairyFree.rawValue) }
                                        if let cheap = recipedict["cheap"] as? Int, cheap == 1 { tags.append(Tag.budget.rawValue) }
                                        
                                        // PHOTO
                                        if let imageURL = recipedict["image"] as? String {
                                            photoURL = imageURL
                                        } else { return }
                                        
                                        // MEALTYPE
                                        if let dishTypes = recipedict["dishTypes"] as? Array<String> {
                                            let dishType = dishTypes.first(where: { meals.contains($0) || $0 == "entree" })
                                            if dishType == nil {
                                                mealtype = "Lunch"
                                                return
                                            }
                                            if dishType == "entree" {
                                                mealtype = "Dinner"
                                            } else {
                                                mealtype = dishType!.capitalized
                                            }
                                        } else { return }
                                        
                                        // TIME
                                        if let readyInMinutes = recipedict["readyInMinutes"] as? Int {
                                            timeInMinutes = readyInMinutes
                                        } else { return }
                                        
                                        // SERVINGS
                                        if let servingsValue = recipedict["servings"] as? Int {
                                            servings = servingsValue
                                        } else { return }
                                        
                                        // TITLE
                                        if let title = recipedict["title"] as? String {
                                            recipeName = title
                                        } else { return }
                                        
                                        let timestamp = Date().timeIntervalSince1970
                                        
                                        var dictionaryToUpload: [String:Any] = [Recipe.nameKey: recipeName,
                                                                                "timestamp": timestamp,
                                                                                Recipe.photoURLKey: photoURL,
//                                                                                Recipe.creatorIDKey: currentUser.uid,
                                                                                Recipe.servingsKey: servings,
                                                                                Recipe.timeInMinutesKey: timeInMinutes,
                                                                                Recipe.difficultyKey: difficulty,
                                                                                Recipe.ingredientsKey: ingredients,
                                                                                Recipe.stepsKey: steps,
                                                                                Recipe.mealKey: mealtype]
                                        
                                        if tags.count != 0 {
                                            dictionaryToUpload[Recipe.tagsKey] = tags
                                        }
                                        
                                        if let countryCode = countryCode,
                                            let locality = locality,
                                            let country = country {
                                            dictionaryToUpload[Recipe.countryCodeKey] = countryCode
                                            dictionaryToUpload[Recipe.localityKey] = locality
                                            dictionaryToUpload[Recipe.countryKey] = country
                                            dictionaryToUpload["longitude"] = longitude
                                            dictionaryToUpload["latitude"] = latitude
                                            
                                            self.createUserAndRecipe(name: name, recipe: dictionaryToUpload)
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
//            }
        }
        
        
    }
    
    var randomNames = ["Cassy","Jonnie","Karine","Neely","Alex","Maira","Christy","Casie","Earline","Germaine","Vannesa","Odessa","Temika","Herminia","Tyisha","Floretta","Lizabeth","Keira","Coletta","Latosha","Lahoma","Shan","Kristian","Jayne","Holly","Ginny","Mildred","Luna","Lilliana","Ceola","Augustus","John","Vonda","Christiana","Todd","Isidro","Brande","Herbert","Clelia","Olevia","Lauralee","Meryl","Adelia","Rosalyn","Venita","Sherilyn","Shanae","Ervin","Linwood","Yolande","Vinnie","Lazaro","Dede","Juli","Kit","Wilbur","Luis","Janay","Enoch","Trista","Aracely","Mariano","Graciela","Rosemarie","Maxwell","Noelia","Damien","Louella","Terica","Gracia","Pansy","Bridget","Inocencia","Lana","Bula","Modesta","Marlen","Elina","Arnita","Lovie","Kiana","Frances","Clarinda","Loura","Helen","Rosalba","Vernita","Chasidy","Ema","Danyelle","Terence","Albina","Marg","Betty","Hye","Pei","Claudie","Sadie","Mikaela","Krystle","Deadra","Alejandra","Alaine","Francisca","Angelika","Hildegard","Walton","Morris","Andera","Candyce","Renaldo","Celesta","Robby","Taina","Venetta","Sumiko","Shandra","Lakenya","Illa","Reuben","Annalisa","Byron","Jaime","Shaunna","Johnnie","Aisha","Christia","Tim","Jennine","Elva","Laquanda","Tammie","Ehtel","Douglass","Dawne","Amee","Mittie","Rusty","Eduardo","Raul","Vicki","Earleen","Mercy","Judith","Jeni","Ashly","Georgene","Leonarda","Davis","Nanci","Ozie","Vera","Emelda","Jeannette","Sylvia","Monserrate","Charisse","Cherry","Towanda","Linnea","Lanie","Augustine","Latonya","Brice","Kimberli","Ken","Vita","Cruz","Dorian","Joe","Delena","Trent","Jefferson","Damaris","Kisha","Raphael","Rosalina","Eliz","Kali","Lorilee","Beth","Madelene","Aimee","Michiko","Avelina","Macy","August","Golda","Leeann","Nellie","Levi","Debbi","Lekisha","Jeremy","Charity","Thora","Latoria","Sandee","Jackie","Erline","Marcie","Christiane","Annett","Leandra","Felicitas","Annemarie","Blythe","Shad","Yelena","Cornelia","Earnestine","Charlie","Charles","Mara","Janene","Suellen","Julienne","Magnolia","Dani","Trisha","Sharri","Amber","Lilliam","Lacy","Margarita","Berna","Lashaunda","Eleanor","Carlton","Richie","Janella","Lavette","Catherin","Manual","Karolyn","Shon","Georgiana","Bernardina","Jinny","Jasper","Lashay","Oretha","Kala","Concetta","Ernesto","Tennie","Nguyet","Stan","Angel","Mitch","Dominick","Kathie","Eddie","Awilda","Kyle","Mendy","Angelica","Nelida","Nola","Tammara","Ann","Genie","Hortencia","Valrie","Patience","Shaina","Peggie","Laurie","Janiece","Alejandrina","Chloe","Trudi","Keneth","Curt","Charleen","Katelin","Shanda","Coralee","Loretta","Kallie","Marylee","Edward","Norris","Cleora","Katharyn","Irvin","Chiquita","Jesus","Staci","Jone","Deon","Renato","Angelic","Donita","Librada","Basilia","Cora","Dan","Darin","Sima","Lyn","Cami","Setsuko","Sam","Alycia","Emely","Toni","Alise","Cherrie","Natosha","Agnes","Onie","Bernardine","Inger","Sari","Karoline","Mertie","Elise","Slyvia","Loris","Estella","Millard","Alexandria","Cherelle","Kaley","Marissa","Daine","Janette","Jenice","Gregg","Flora","Williams","Lula","Ginger","Brock","James","Suzanna","Shara","Simon","Caryn","Meghan","Carolina","Delmar","Delphia","Dylan","Latesha","Cecille","Birdie","Blanch","Sabine","Jose","Harold","Ricarda","Jacqui","Jo","Tory","Birgit","Sonya","Jere","Joanna","Rashad","Alden","Rutha","Kellye","Antonia","Melani","Jolynn","Shela","Mohammad","Francine","Julianna","Christa","Santa","Quentin","Demarcus","Alysia","Bertie","Charmaine","Hsiu","Kathaleen","Sebrina","Francina","Starr","Luciano","Alaina","Gail","Carrie","Rozella","Lorenza","Quintin","Deja","Louvenia","Lovella","Lanora","Manda","Keesha","Kandi","Mark","Marin","Broderick","Bev","Kimber","Jody","Paige","Gertrud","Viki","Angelina","Cortez","Ira","Hedy","Nathanael","Madonna","Abbie","Teisha","Richelle","Brooke","Mel","Ninfa","Mary","Chae","Celinda","Stefany","Rachelle","Zada","Buford","Bonny","Anibal","Jaimie","Haywood","Layla","Thi","Denver","Rachal","Usha","Delicia","Kiesha","Dewitt","Harland","Suzanne","Janita","Justine","Doloris","Susannah","Wan","Bess","Horace","Maryjane","Waneta","Branden","Christena","Chery","Karry","Maryjo","Darrel","Dotty","Mira","Roman","Hwa","Lakeesha","Lorretta","Roger","Houston","Merrill","Debora","Jena","Elana","Tyrell","Octavio","Marlo","Jaclyn","Holley","Elida","Kendrick","Brigida","Fernanda","Demetria","Marlene","Pattie","Emory","Vivian","Gerardo","Roseanne"]
    
    func createUserAndRecipe(name: String, recipe: [String:Any]) {

        let password = "fakeuser"
        
        FirebaseController.shared.verifyUniqueUsername(name) { (isUnique) in
            var newName = name
            var email = "\(newName)@tastytravelerapp.com"
            
            if !isUnique {
                let randomNumber = Int(arc4random_uniform(UInt32(1 + 99 - 1))) + 1
                newName = "\(name)\(randomNumber)"
                email = "\(newName)@tastytravelerapp.com"
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                }
                
                if let user = user {
                    FirebaseController.shared.ref.child("users").child(user.uid).child("badgeCount").setValue(0)
                    FirebaseController.shared.ref.child("users").child(user.uid).child("unreadMessagesCount").setValue(0)
                    FirebaseController.shared.storeUsername(newName, uid: user.uid, completion: { (stored) in
                        // create and store recipe
                        let recipeID = UUID().uuidString

                        let locality = recipe[Recipe.localityKey] as! String
                        let country = recipe[Recipe.countryKey] as! String
                        let countryCode = recipe[Recipe.countryCodeKey] as! String
                        
                        var updatedRecipe = recipe
                        updatedRecipe[Recipe.creatorIDKey] = user.uid
                        
                        FirebaseController.shared.ref.child("localities").updateChildValues([locality: true])
                        FirebaseController.shared.ref.child("locations").child(country).updateChildValues(["countryCode": countryCode])
                        FirebaseController.shared.ref.child("locations").child(country).child("recipes").child(recipeID).setValue(true)

                        FirebaseController.shared.ref.child("recipes").child(recipeID).setValue(updatedRecipe)
                        
                        FirebaseController.shared.ref.child("users").child(user.uid).child("uploadedRecipes").child(recipeID).setValue(true)
                    })
                }
            }
        }
    }
    
    func verifyUserAndLogin(user: User) {
        
        FirebaseController.shared.isUsernameStored(uid: user.uid, completion: { (result) in
            SVProgressHUD.dismiss()
            if result {
                let mainTabBarController = MainTabBarController()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                
                appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
                UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                    appDelegate.window?.rootViewController = mainTabBarController
                }, completion: nil)
                
            } else {
                let signUpVC = SignUpVC()
                signUpVC.isFromFacebookLogin = true
                signUpVC.isHeroEnabled = true
                signUpVC.view.heroModifiers = [.fade]
                self.present(signUpVC, animated: true, completion: nil)
            }
        })
        print("successfully signed in using firebase")
    }
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logIn(readPermissions: [.email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                SVProgressHUD.show()
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error)
                        if (error as NSError).code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
                            
                            if let userEmail = (error as NSError).userInfo[AuthErrorUserInfoEmailKey] as? String {
                                let ac = UIAlertController(title: "Existing Account", message: "There is an account registered to the email associated with your Facebook account. Enter your password to merge accounts.", preferredStyle: .alert)
                                ac.addTextField(configurationHandler: { (textField) in
                                    textField.placeholder = "Enter password"
                                    textField.isSecureTextEntry = true
                                })
                                ac.addAction(UIAlertAction(title: "Merge", style: .default, handler: { (_) in
                                    guard let text = ac.textFields![0].text else { return }
                                    
                                    SVProgressHUD.show()
                                    
                                    let emailCredential = EmailAuthProvider.credential(withEmail: userEmail, password: text)
                                    
                                    Auth.auth().signIn(with: emailCredential, completion: { (user, error) in
                                        if let error = error {
                                            print(error)
                                            SVProgressHUD.showError(withStatus: "Incorrect password")
                                            return
                                        }
                                        
                                        user!.link(with: credential, completion: { (user, error) in
                                            if let error = error {
                                                print(error)
                                                SVProgressHUD.dismiss()
                                                return
                                            }
                                            
                                            if let user = user {
                                                self.verifyUserAndLogin(user: user)
                                            }
                                        })
                                    })
                                }))
                                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                self.present(ac, animated: true, completion: nil)
                            }
                        }
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    if let user = user {
                        
                        self.verifyUserAndLogin(user: user)
                    }
                })
            }
        }
    }
}
