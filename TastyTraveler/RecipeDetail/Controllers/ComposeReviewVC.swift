//
//  ComposeReviewVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/8/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import SVProgressHUD

class ComposeReviewVC: UITableViewController, UITextViewDelegate {
    
    var review: Review? {
        didSet {
            if let rating = review?.rating {
                self.ratingControl.rating = Double(rating)
            }
            
            if let title = review?.title {
                self.titleTextField.text = title
            }
            
            if let text = review?.text, text != "" {
                self.reviewTextView.placeholderLabel.isHidden = true
                self.reviewTextView.text = text
                textViewDidChange(reviewTextView)
            }
        }
    }
    
    var userID: String!
    var recipeID: String!
    weak var recipeDetailVC: RecipeDetailVC!
    
    var ratingCell = UITableViewCell()
    var titleCell = UITableViewCell()
    var reviewCell = UITableViewCell()
    
    var ratingControl = CosmosView()
    var titleTextField = UITextField()
    var reviewTextView = TextInputTextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingControl.rating = 0
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .white
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .white
        
        navigationItem.title = "Write Review"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(doneTapped))
        
        fetchExistingReview()
    }
    
    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneTapped() {
        guard titleTextField.text != "", reviewTextView.text != "", ratingControl.rating != 0 else { return }
        
        let newRating = Int(ratingControl.rating)
        let newTitle = titleTextField.text
        let newReviewText = reviewTextView.text
        
        if review != nil {
            review?.title = newTitle
            review?.text = newReviewText
            review?.rating = newRating
            
            FirebaseController.shared.saveReview(review!, forRecipeID: recipeID)
        } else {
            let uid = UUID().uuidString
            let timestamp = Date().timeIntervalSince1970
            let dictionary: [String:Any] = ["title": titleTextField.text!,
                                            "text": reviewTextView.text,
                                            "timestamp": timestamp,
                                            "rating": ratingControl.rating,
                                            "reviewerID": userID,
                                            "recipeID": recipeID]
            
            FirebaseController.shared.ref.child("reviews").child(uid).setValue(dictionary)
            FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").updateChildValues([recipeID: uid])
            FirebaseController.shared.ref.child("recipes").child(recipeID).child("reviews").updateChildValues([userID: uid])
            
            NotificationCenter.default.post(name: Notification.Name("submittedReview"), object: nil)
        }
        
        recipeDetailVC.didSubmitReview = true
        dismiss(animated: true, completion: nil)
    }
    
    func fetchExistingReview() {
        FirebaseController.shared.ref.child("users").child(userID).child("reviewedRecipes").child(recipeID).observeSingleEvent(of: .value) { (snapshot) in
            guard let reviewID = snapshot.value as? String else {
                // User has not reviewed recipe yet
                return
            }
            
            FirebaseController.shared.ref.child("reviews").child(reviewID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let reviewDictioanry = snapshot.value as? [String:Any] else { return }
                
                self.review = Review(uid: reviewID, dictionary: reviewDictioanry)
                self.navigationItem.title = "Edit Review"
            })
        }
    }
    
    override func loadView() {
        super.loadView()
        
        // RATING CELL
        ratingControl.settings.emptyColor = .white
        ratingControl.settings.emptyBorderColor = Color.primaryOrange
        ratingControl.settings.filledColor = Color.primaryOrange
        ratingControl.settings.starSize = 30
        ratingControl.settings.starMargin = 10
        ratingControl.settings.fillMode = .full
        ratingControl.settings.updateOnTouch = true
        ratingControl.settings.textFont = ProximaNova.regular.of(size: 11)
        
        self.ratingCell.sv(ratingControl)
        ratingControl.centerInContainer()
        
        // TITLE CELL
        
        self.titleCell.sv(titleTextField)
        titleTextField.top(adaptConstant(12)).bottom(adaptConstant(12)).left(adaptConstant(12)).right(adaptConstant(12))
        titleTextField.font = ProximaNova.regular.of(size: 16)
        titleTextField.textColor = Color.darkText
        titleTextField.placeholder = "Title"
        
        // REVIEW CELL
        self.reviewCell.sv(reviewTextView)
        reviewTextView.placeholderLabel.text = "Review"
        reviewTextView.placeholderLabel.font = ProximaNova.regular.of(size: 16)
        reviewTextView.font = ProximaNova.regular.of(size: 16)
        reviewTextView.textColor = Color.darkText
        reviewTextView.placeholderLabel.leftConstraint?.constant = 0
        reviewTextView.delegate = self
        reviewTextView.showPlaceholderLabel()
        reviewTextView.textContainerInset = UIEdgeInsets.zero
        reviewTextView.textContainer.lineFragmentPadding = 0
        reviewTextView.isScrollEnabled = false
        reviewTextView.top(adaptConstant(12)).left(adaptConstant(12)).right(adaptConstant(12)).bottom(0)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.height(1)
        view.width(tableView.frame.width)
        return view
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return self.ratingCell
        case 1:
            return self.titleCell
        case 2:
            return self.reviewCell
        default:
            fatalError("Unknown row")
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newHeight = reviewCell.frame.size.height + textView.contentSize.height
        reviewCell.frame.size.height = newHeight
        updateTableViewContentOffsetForTextView()
    }
    
    func updateTableViewContentOffsetForTextView() {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
}
