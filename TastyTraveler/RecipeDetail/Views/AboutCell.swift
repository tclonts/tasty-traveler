//
//  AboutCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/29/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import MapKit
import FirebaseAuth
import Firebase

class AboutCell: BaseCell {
    
    // MARK: - Views
    let scrollView = UIScrollView()
    
    /// Container view for the Servings, Time, and Difficulty boxes
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.offWhite
        view.height(adaptConstant(138))
        return view
    }()
    
    let servingsInfoBox: InfoBox = {
        let infoBox = InfoBox()
        infoBox.infoImageView.image = #imageLiteral(resourceName: "servingsIcon")
        infoBox.infoLabel.text = "Serves 4"
        return infoBox
    }()
    
    let timeInfoBox: InfoBox = {
        let infoBox = InfoBox()
        infoBox.infoImageView.image = #imageLiteral(resourceName: "timeIcon")
        infoBox.infoLabel.text = "25 minutes"
        return infoBox
    }()
    
    let difficultyInfoBox: InfoBox = {
        let infoBox = InfoBox()
        infoBox.infoImageView.image = #imageLiteral(resourceName: "difficultyIcon")
        infoBox.infoLabel.text = "Easy"
        return infoBox
    }()
    
    let descriptionStackView = UIStackView()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = ProximaNova.bold.of(size: 20)
        label.textColor = Color.darkText
        return label
    }()
    
    let descriptionText: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    lazy var tagsCollectionView: UICollectionView = {
        let layout = FlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "tagCell")
        return collectionView
    }()
    
    lazy var cookedItImageCollectionView: UICollectionView = {
        let layout = FlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .blue
        collectionView.register(cookedImageCell.self, forCellWithReuseIdentifier: "cookedImageCell")
        return collectionView
    }()
    
    let ratingsView = RatingsView()
    
    let reviewsStackView = UIStackView()
    
    let reviewsLabel: UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.font = ProximaNova.bold.of(size: 20)
        label.textColor = Color.darkText
        return label
    }()
    
    lazy var writeReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "composeIcon"), for: .normal)
        button.setTitle("Write a review", for: .normal)
        button.titleLabel?.font = ProximaNova.regular.of(size: 14)
        button.titleLabel?.textColor = UIColor(hexString: "4A90E2")
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        button.addTarget(self, action: #selector(writeReviewButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var reviewsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 110
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "reviewCell")
        return tableView
    }()
    
    // MARK: - Properties
    var review: Review? {
        didSet {
            if review?.rating != nil {
                self.ratingsView.ratingControl.rating = Double(review!.rating!)
            }
        }
    }
    
    var reviewsWithText = [Review]()
    var recipeDetailVC: RecipeDetailVC?
    var recipeID: String!
    weak var delegate: AboutCellDelegate?
    let margin = adaptConstant(16)
    
    // MARK: - Override Methods
    override func setUpViews() {
        super.setUpViews()
        
        setUpNotifications()
        
        setUpInfoView()
        setUpDescriptionView()
        
        tagsCollectionView.left(adaptConstant(25)).right(adaptConstant(25)).height(100)
        cookedItImageCollectionView.left(adaptConstant(25)).right(adaptConstant(25)).height(100)
        
        setUpRatingsView()
        setUpReviewsView()
        
        let stackView = UIStackView(arrangedSubviews: [infoView, descriptionStackView, tagsCollectionView, cookedItImageCollectionView, ratingsView, reviewsStackView, reviewsTableView])
        
        scrollView.sv(stackView)
        stackView.fillContainer()
        stackView.Width == scrollView.Width
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = adaptConstant(27)
        
        sv(scrollView)
        scrollView.contentInset.bottom = 20
        scrollView.fillContainer()
        scrollView.isScrollEnabled = false
        
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setUpRatings()
    }
    
    // MARK: - Private Methods
    private func setUpNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadReviews), name: Notification.Name("ReviewsLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserRating), name: Notification.Name("submittedReview"), object: nil)
    }
    
    private func setUpInfoView() {
        infoView.sv(servingsInfoBox, timeInfoBox, difficultyInfoBox)
        
        infoView.top(0).left(0).right(0).width(self.frame.width)
        
        infoBoxConstraints(for: servingsInfoBox, imageWidth: 48, imageHeight: 31)
        infoBoxConstraints(for: timeInfoBox, imageWidth: 38, imageHeight: 38)
        infoBoxConstraints(for: difficultyInfoBox, imageWidth: 36, imageHeight: 36)
        
        infoView.layout(
            margin,
            |-margin-servingsInfoBox-margin-timeInfoBox-margin-difficultyInfoBox-margin-|,
            margin
        )
    }
    
    private func infoBoxConstraints(for infoBox: InfoBox, imageWidth: CGFloat, imageHeight: CGFloat) {
        infoBox.width((self.frame.width - (margin * 4)) / 3)
        infoBox.heightEqualsWidth()
        infoBox.infoImageView.centerHorizontally()
        infoBox.infoImageView.width(adaptConstant(imageWidth)).height(adaptConstant(imageHeight))
        infoBox.infoLabel.centerHorizontally()
        infoBox.infoLabel.Top == infoBox.infoImageView.Bottom + adaptConstant(12)
        infoBox.infoLabel.bottom(adaptConstant(16))
    }
    
    private func setUpDescriptionView() {
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(descriptionText)
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = adaptConstant(18)
        
        descriptionStackView.left(adaptConstant(25)).right(adaptConstant(25))
    }
    
    private func setUpRatingsView() {
        ratingsView.aboutCell = self
        
        ratingsView.height(adaptConstant(160)).left(0).right(0)
        
        toggleRatingsView()
    }
    
    private func toggleRatingsView() {
        if let hasCooked = recipeDetailVC?.recipe?.hasCooked, hasCooked {
            ratingsView.errorText.isHidden = true
            ratingsView.tapToRateLabel.isHidden = false
            ratingsView.ratingControl.isHidden = false
        } else {
            ratingsView.errorText.isHidden = false
            ratingsView.tapToRateLabel.isHidden = true
            ratingsView.ratingControl.isHidden = true
        }
    }
    
    private func setUpReviewsView() {
        reviewsStackView.addArrangedSubview(reviewsLabel)
        reviewsStackView.addArrangedSubview(writeReviewButton)
        reviewsStackView.axis = .horizontal
        
        reviewsLabel.left(0)
        reviewsLabel.textAlignment = .left
        //reviewsLabel.left(adaptConstant(25))
        
        writeReviewButton.right(0)
        writeReviewButton.contentHorizontalAlignment = .right
        
        reviewsStackView.left(adaptConstant(25)).right(adaptConstant(12))
        reviewsTableView.left(adaptConstant(12)).right(adaptConstant(12)).height(110)
    }
    
    private func setUpRatings() {
        guard let ratings = recipeDetailVC?.ratings, let averageRating = recipeDetailVC?.averageRating else {
            ratingsView.oneStarBar.fillRatio = CGFloat(0)
            ratingsView.twoStarBar.fillRatio = CGFloat(0)
            ratingsView.threeStarBar.fillRatio = CGFloat(0)
            ratingsView.fourStarBar.fillRatio = CGFloat(0)
            ratingsView.fiveStarBar.fillRatio = CGFloat(0)
            
            let ratingText = String(format: "%.1f", 0)
            ratingsView.ratingLabel.text = ratingText
            ratingsView.numberOfRatingsLabel.text = "0 Ratings"
            return
        }
        
        let numberOfRatings = ratings.count
        let oneStarRatio = (ratings.filter { $0 == 1 }.count) / numberOfRatings
        let twoStarRatio = (ratings.filter { $0 == 2 }.count) / numberOfRatings
        let threeStarRatio = (ratings.filter { $0 == 3 }.count) / numberOfRatings
        let fourStarRatio = (ratings.filter { $0 == 4 }.count) / numberOfRatings
        let fiveStarRatio = (ratings.filter { $0 == 5 }.count) / numberOfRatings
        
        ratingsView.oneStarBar.fillRatio = CGFloat(oneStarRatio)
        ratingsView.twoStarBar.fillRatio = CGFloat(twoStarRatio)
        ratingsView.threeStarBar.fillRatio = CGFloat(threeStarRatio)
        ratingsView.fourStarBar.fillRatio = CGFloat(fourStarRatio)
        ratingsView.fiveStarBar.fillRatio = CGFloat(fiveStarRatio)
        
        let ratingText = String(format: "%.1f", averageRating)
        ratingsView.ratingLabel.text = ratingText
        ratingsView.numberOfRatingsLabel.text = "\(numberOfRatings) Ratings"
        
        ratingsView.layoutSubviews()
        ratingsView.oneStarBar.layoutSubviews()
    }
    
    // MARK: - Selector Methods
    @objc func loadReviews() {
        setUpRatings()
        
        self.reviewsWithText = recipeDetailVC!.reviews.filter { $0.text != nil }
        
        reviewsTableView.reloadData()
        
        if recipeDetailVC!.didSubmitReview {
            recipeDetailVC?.didSubmitReview = false
        }
        
        if recipeDetailVC?.recipe?.tags != nil {
            tagsCollectionView.reloadData()
            let height = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
            tagsCollectionView.heightConstraint?.constant = height
        } else {
            tagsCollectionView.heightConstraint?.constant = 0
        }
        
        if recipeDetailVC?.recipe?.cookedImages != nil {
            cookedItImageCollectionView.reloadData()
            let height = cookedItImageCollectionView.collectionViewLayout.collectionViewContentSize.height
            cookedItImageCollectionView.heightConstraint?.constant = height
        } else {
            cookedItImageCollectionView.heightConstraint?.constant = 0
        }
        
        self.layoutIfNeeded()
        reviewsTableView.heightConstraint?.constant = reviewsTableView.contentSize.height + 24
        self.layoutIfNeeded()
        
        delegate?.resizeCollectionView(forHeight: self.scrollView.contentSize.height, cell: self)
    }
    
    @objc func refreshUserRating() {
        FirebaseController.shared.fetchUserReview(forRecipeID: recipeID) { (review) in
            guard let review = review else { return }
            self.review = review
        }
        
        toggleRatingsView()
    }
    
    @objc func writeReviewButtonTapped() {
        delegate?.presentComposeReviewView()
    }
}

extension AboutCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tags = recipeDetailVC?.recipe?.tags else { return 0 }
        guard let cookedImages = recipeDetailVC?.recipe?.cookedImages else { return 0 }
        if collectionView == tagsCollectionView {
            return tags.count
        } else if collectionView == cookedItImageCollectionView {
            return cookedImages.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == tagsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
            
            guard let tags = recipeDetailVC?.recipe?.tags else { return UICollectionViewCell() }
            
            let tag = tags[indexPath.item].rawValue
            
            let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font:             ProximaNova.semibold.of(size: 16),
                                                                                NSAttributedStringKey.foregroundColor: UIColor.white])
            cell.tagLabel.attributedText = attributedString
            cell.isSelected = true
            cell.setUpViews()
            
            return cell
        } else if collectionView == self.cookedItImageCollectionView {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cookedImageCell", for: indexPath) as? cookedImageCell else { return UICollectionViewCell() }
            
            guard let cookedImage = recipeDetailVC?.recipe?.cookedImages![indexPath.row] else { return UICollectionViewCell() }
            
            
            for value in cookedImage.values {
                cell.cookedImageView.loadImage(urlString: value, placeholder: #imageLiteral(resourceName: "avatar"))
            }
            
            let userID = Auth.auth().currentUser?.uid
            FirebaseController.shared.fetchUserWithUID(uid: userID!) { (user) in
                guard let user = user else { return}
                
                cell.userNameLabel.text = user.username
                cell.isSelected = true
                cell.setUpViews()
            }
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView {
            guard let tags = recipeDetailVC?.recipe?.tags else { return CGSize.zero }
            
            let tag = tags[indexPath.item].rawValue
            
            let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font: ProximaNova.semibold.of(size: 16),
                                                                                NSAttributedStringKey.foregroundColor: UIColor.white])
            return CGSize(width: attributedString.size().width + adaptConstant(24), height: adaptConstant(27))
            
        } else if collectionView == cookedItImageCollectionView {
            guard let cookedImages = recipeDetailVC?.recipe?.cookedImages else { return CGSize.zero }
            
            let images = cookedImages.reduce([], +)
            
            let image = images[indexPath.row].value
           
            let attributedString = NSAttributedString(string: image, attributes: [NSAttributedStringKey.font: ProximaNova.semibold.of(size: 16),
                                                                                        NSAttributedStringKey.foregroundColor: UIColor.white])
            return CGSize(width: attributedString.size().width + adaptConstant(24), height: adaptConstant(27))
        
            
        } else {
            return CGSize()
        }
    }
}

extension AboutCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsWithText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewCell
        
        cell.review = reviewsWithText[indexPath.row]
        cell.reviewsTableView = reviewsTableView
        
        return cell
    }
}

protocol AboutCellDelegate: class {
    func presentComposeReviewView()
    func resizeCollectionView(forHeight height: CGFloat, cell: UICollectionViewCell)
}
