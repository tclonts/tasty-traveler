//
//  PointsVC.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 8/28/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AMProgressBar
import Stevia
import Eureka
import SVProgressHUD
import RKPieChart



class PointsVC: UIViewController {
    
    var user: TTUser? {
        didSet {
        if let userPoints = user?.points {
          totalPoints = userPoints
        }
    }
    }
    
    
    let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.blackText
        label.text = "Points"
        label.textAlignment = .center
//        label.width(350)
        return label
    }()
    
    let youHave: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.blackText
        label.text = "youHave"
        label.textAlignment = .center

        return label
    }()
    
    let someOneHas: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 12)
        label.textColor = Color.blackText
        label.text = "SomeONeHas"
        label.textAlignment = .center

        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarConfiguration()
        youCooked()
        youFavorited()
        theyCookedRecipes()
        theyFavorite()
        theyReview()
        youReview()
   
        fetchUserInfo {
            
            
            let firstItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.yourCooked)), color: Color.filledBar, title: "recipes cooked by you")
            let secondItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.yourFavorited)), color: Color.blackText, title: "recipes saved by you")
            let thirdItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.yourReviewed)), color: Color.darkText , title: "reviews left by you")
            let fourthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.theyCooked)), color: Color.primaryOrange , title: "recipes cooked by others")
            let fifthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.theyFavorited)), color: Color.offWhite , title: "recipes favorited by others")
            let sixthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(self.theyReviewed)), color: Color.lightGray, title: "review left by others")
            let chartView = RKPieChartView(items: [firstItem, secondItem, thirdItem, fourthItem, fifthItem, sixthItem], centerTitle: ("Total Points \(self.totalPoints)"))
            
            chartView.circleColor = .clear
            chartView.translatesAutoresizingMaskIntoConstraints = false
            chartView.arcWidth = 40
            chartView.isIntensityActivated = false
            chartView.style = .butt
            chartView.isTitleViewHidden = false
            chartView.isAnimationActivated = true
            
            
            
            let stackViewVertical = UIStackView(arrangedSubviews: [chartView])
            stackViewVertical.axis = .vertical
            stackViewVertical.distribution = .fillEqually
            
            
            self.view.sv(stackViewVertical)
            stackViewVertical.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
           stackViewVertical.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
            stackViewVertical.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            stackViewVertical.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUserInfo), name: Notification.Name("UserInfoUpdated"), object: nil)

        
       
        
    }
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
    }

    
    @objc func closePoints() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func navBarConfiguration() {
        self.navigationItem.title = "Points"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.view.backgroundColor = UIColor(hexString: "F8F8FB")
        let leftBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closePoints))
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Color.blackText
    }
    
    var theyFavorited = 0
    var theyCooked = 0
    var yourFavorited = 0
    var yourReviewed = 0
    var yourCooked = 0
    var theyReviewed = 0
    var totalPoints = 0
}

extension PointsVC {
    
    func theyFavorite() {
        
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
    for recipe in result.children.allObjects as! [DataSnapshot] {
    
    let recipeUID = recipe.key
    
    FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
    print(snapshot.children.allObjects)
        
        self.theyFavorited = Int(snapshot.childrenCount) * 1
                }
            }
        }
    }
    
    
    func theyCookedRecipes() {
        
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
    for recipe in result.children.allObjects as! [DataSnapshot] {
    
    let recipeUID = recipe.key
    
    FirebaseController.shared.ref.child("recipes").child(recipeUID).child("cookedImages").observeSingleEvent(of: .value) { (snapshot) in
    
    self.theyCooked = Int(snapshot.childrenCount) * 5
        }}}}
    
    
    func youFavorited() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("favorites").observe(.value) { (snapshot) in
            print(snapshot.childrenCount)
            self.yourFavorited = Int(snapshot.childrenCount) * 1

        }
    }
    
    func youCooked() {
       
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").observe(.value) { (snapshot) in
           self.yourCooked = Int(snapshot.childrenCount) * 5
        }
    }
    
    func theyReview() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("reviews").observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot.children.allObjects)
                    
                    self.theyReviewed = Int(snapshot.childrenCount) * 10
                }
            }
        }
    }
    
    func youReview() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("reviewRecipes").observe(.value) { (snapshot) in
            print(snapshot.childrenCount)
            self.yourReviewed = Int(snapshot.childrenCount) * 10
            
        }
    }
    

    
    @objc func fetchUserInfo(completion: @escaping() -> Void) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }

            FirebaseController.shared.fetchUserWithUID(uid: userID, completion: { (user) in
                self.user = user
                completion()
            })
        }
    
}
