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
    
    let pointsInfoButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(string: "Learn how to earn points and get rewards?", attributes: [
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
            NSAttributedStringKey.foregroundColor: Color.primaryOrange])
        button.setAttributedTitle(title, for: .normal)
        button.addTarget(self, action: #selector(learnMore), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUserInfo), name: Notification.Name("UserInfoUpdated"), object: nil)

        navBarConfiguration()
        youCooked()
        youFavorited()
        theyCookedRecipes()
        theyFavorite()
        theyReview()
        youReview()
        youUploaded()
        //        addTotal()
        
        fetchUserInfo {
            var totalP = self.yourFavorited + self.yourReviewed + self.yourCooked
            
            let yourCookedPoints: Double = (Double(self.yourCooked) / Double(totalP)) * 100.0
            let yourFavoritePoints: Double = (Double(self.yourFavorited) / Double(totalP)) * 100.0
            let yourReviewedPoints: Double = (Double(self.yourReviewed) / Double(totalP)) * 100.0
            let theyCookedPoints: Double = (Double(self.theyCooked) / Double(totalP)) * 100.0
            let theyFavoritePoints: Double = (Double(self.theyFavorited) / Double(totalP)) * 100.0
            let theyReviewedPoints: Double = (Double(self.theyReviewed) / Double(totalP)) * 100.0
            let youUploadedPoints: Double = (Double(self.youUploadedRecipe) / Double(totalP)) * 100.0
        
            
            let firstItem: RKPieChartItem = RKPieChartItem(ratio: (uint(yourCookedPoints)), color: Color.orange, title: "recipes cooked by you = 5 points")
            let secondItem: RKPieChartItem = RKPieChartItem(ratio: (uint(yourFavoritePoints)), color: Color.blue, title: "recipes favorited by you = 1 point")
            let thirdItem: RKPieChartItem = RKPieChartItem(ratio: (uint(yourReviewedPoints)), color: Color.darkText , title: "reviews left by you = 10 points")
            let fourthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(theyCookedPoints)), color: Color.pink , title: "recipes cooked by others = 5 points")
            let fifthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(theyFavoritePoints)), color: Color.purple , title: "recipes favorited by others = 1 point")
            let sixthItem: RKPieChartItem = RKPieChartItem(ratio: (uint(theyReviewedPoints)), color: Color.yellow, title: "review left by others = 10 points")
            let seventhItem: RKPieChartItem = RKPieChartItem(ratio: (uint(youUploadedPoints)), color: Color.green, title: "recipe uploaded by you = 10 points")
            let chartView = RKPieChartView(items: [seventhItem, thirdItem, firstItem, secondItem, sixthItem, fourthItem, fifthItem], centerTitle: ("Total Points \(self.totalPoints)"))
            
            let stackViewVertical = UIStackView(arrangedSubviews: [chartView])
            stackViewVertical.axis = .vertical
            stackViewVertical.distribution = .fillEqually
            
            chartView.circleColor = .white
            chartView.translatesAutoresizingMaskIntoConstraints = false
            chartView.arcWidth = 40
            chartView.isIntensityActivated = false
            chartView.style = .butt
            chartView.isTitleViewHidden = false
            chartView.isAnimationActivated = true
            
            
            
            
            self.view.sv(self.pointsInfoButton, stackViewVertical)
            stackViewVertical.topAnchor.constraint(equalTo: self.pointsInfoButton.bottomAnchor).isActive = true
            stackViewVertical.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20 ).isActive = true
            stackViewVertical.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            stackViewVertical.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.pointsInfoButton.Top == self.view.Top + 20
            self.pointsInfoButton.centerHorizontally()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    @objc func closePoints() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func learnMore() {
        let learnMoreVC = LearnMoreVC()
        learnMoreVC.modalPresentationStyle = .overCurrentContext
        self.present(learnMoreVC, animated: false) {
        }
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
    
    var youUploadedRecipe = 0
    var theyFavorited = 0
    var theyCooked = 0
    var yourFavorited = 0
    var yourReviewed = 0
    var yourCooked = 0
    var theyReviewed = 0
    var totalPoints = 0
//    var isMyPoints = true
}

extension PointsVC {
    
    
    func youUploaded () {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observe(.value) { (snapshot) in
            if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                self.youUploadedRecipe = (Int(snapshot.childrenCount) * 20)
        }
    }
    }
    
    func theyFavorite() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("favoritedBy").observeSingleEvent(of: .value) { (snapshot) in
                    if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                        self.theyFavorited = (Int(snapshot.childrenCount) * 1)                    }
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
                    if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                        self.theyCooked = (Int(snapshot.childrenCount) * 5)
                    }
                }}}}
    
    
    func youFavorited() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("favorites").observe(.value) { (snapshot) in
            if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                self.yourFavorited = (Int(snapshot.childrenCount) * 1)
            }
        }
    }
    
    func youCooked() {
        
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("cookedRecipes").observe(.value) { (snapshot) in
            if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                self.yourCooked = (Int(snapshot.childrenCount) * 5)
            }
        }
    }
    
    func theyReview() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("uploadedRecipes").observeSingleEvent(of: .value) { (result) in
            for recipe in result.children.allObjects as! [DataSnapshot] {
                
                let recipeUID = recipe.key
                
                FirebaseController.shared.ref.child("recipes").child(recipeUID).child("reviews").observeSingleEvent(of: .value) { (snapshot) in
                    if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                        self.theyReviewed = (Int(snapshot.childrenCount) * 10)
                    }
                }
            }
        }
    }
    
    func youReview() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").observe(.value) { (snapshot) in
            if (snapshot.childrenCount) != 0 && (snapshot.childrenCount) != nil {
                self.yourReviewed = (Int(snapshot.childrenCount) * 10)
            }
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
