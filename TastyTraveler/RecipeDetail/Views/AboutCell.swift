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

class FlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        
        var leftMargin: CGFloat = 0.0;
        
        for attributes in attributesForElementsInRect! {
            if (attributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                var newLeftAlignedFrame = attributes.frame
                newLeftAlignedFrame.origin.x = leftMargin
                attributes.frame = newLeftAlignedFrame
            }
            leftMargin += attributes.frame.size.width + 8
            newAttributesForElementsInRect.append(attributes)
        }
        
        return newAttributesForElementsInRect
    }
}

class AboutCell: BaseCell {
    
    let scrollView = UIScrollView()
    
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F8F8FB")
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
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
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
        //layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: "tagCell")
        return collectionView
    }()
    
    let ratingsView = RatingsView()
    
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
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.activityIndicatorViewStyle = .gray
        indicator.hidesWhenStopped = true
        return indicator
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
    
    override func setUpViews() {
        super.setUpViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadReviews), name: Notification.Name("ReviewsLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUserRating), name: Notification.Name("submittedReview"), object: nil)
        
        infoView.sv(servingsInfoBox, timeInfoBox, difficultyInfoBox)
        ratingsView.aboutCell = self
        
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(descriptionText)
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = adaptConstant(18)
        
        let reviewsStackView = UIStackView(arrangedSubviews: [reviewsLabel, writeReviewButton])
        reviewsStackView.axis = .horizontal
        reviewsLabel.left(0)
        reviewsLabel.textAlignment = .left
        writeReviewButton.right(0)
        writeReviewButton.contentHorizontalAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [infoView, descriptionStackView, tagsCollectionView, ratingsView, reviewsStackView, reviewsTableView])
        
        reviewsStackView.left(adaptConstant(25)).right(adaptConstant(12))
        tagsCollectionView.left(adaptConstant(25)).right(adaptConstant(25))
        tagsCollectionView.height(100)
        activityIndicator.centerInContainer()
        
        let margin = adaptConstant(16)
        
        scrollView.sv(stackView)
        
        stackView.fillContainer()
        stackView.Width == scrollView.Width
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = adaptConstant(27)
        
        reviewsTableView.left(adaptConstant(12)).right(adaptConstant(12)).height(110)
        descriptionStackView.left(adaptConstant(25)).right(adaptConstant(25))
        ratingsView.height(adaptConstant(160)).left(0).right(0)
        
        if let hasCooked = recipeDetailVC?.recipe?.hasCooked, hasCooked {
            ratingsView.errorText.isHidden = true
            ratingsView.tapToRateLabel.isHidden = false
            ratingsView.ratingControl.isHidden = false
        } else {
            ratingsView.errorText.isHidden = false
            ratingsView.tapToRateLabel.isHidden = true
            ratingsView.ratingControl.isHidden = true
        }
        
        setUpRatings()
        
        sv(scrollView)
        scrollView.contentInset.bottom = 20
        scrollView.fillContainer()
        scrollView.isScrollEnabled = false
        
        infoView.top(0).left(0).right(0).width(self.frame.width)
        
        let width = (self.frame.width - (margin * 4)) / 3
        
        servingsInfoBox.width(width)
        servingsInfoBox.heightEqualsWidth()
        servingsInfoBox.infoImageView.centerHorizontally()
        servingsInfoBox.infoImageView.width(adaptConstant(48)).height(adaptConstant(31))
        servingsInfoBox.infoLabel.centerHorizontally()
        servingsInfoBox.infoLabel.Top == servingsInfoBox.infoImageView.Bottom + adaptConstant(12)
        servingsInfoBox.infoLabel.bottom(adaptConstant(16))
        
        timeInfoBox.width(width)
        timeInfoBox.heightEqualsWidth()
        timeInfoBox.infoImageView.centerHorizontally()
        timeInfoBox.infoImageView.width(adaptConstant(38)).height(adaptConstant(38))
        timeInfoBox.infoLabel.centerHorizontally()
        timeInfoBox.infoLabel.Top == timeInfoBox.infoImageView.Bottom + adaptConstant(12)
        timeInfoBox.infoLabel.bottom(adaptConstant(16))
        
        difficultyInfoBox.width(width)
        difficultyInfoBox.heightEqualsWidth()
        difficultyInfoBox.infoImageView.centerHorizontally()
        difficultyInfoBox.infoImageView.width(adaptConstant(36)).height(adaptConstant(36))
        difficultyInfoBox.infoLabel.centerHorizontally()
        difficultyInfoBox.infoLabel.Top == difficultyInfoBox.infoImageView.Bottom + adaptConstant(12)
        difficultyInfoBox.infoLabel.bottom(adaptConstant(16))
        
        infoView.layout(
            margin,
            |-margin-servingsInfoBox-margin-timeInfoBox-margin-difficultyInfoBox-margin-|,
            margin
        )
        
        reviewsLabel.left(adaptConstant(25))
        
        delegate?.resizeCollectionView(forHeight: self.scrollView.contentSize.height)
        
        backgroundColor = .white
    }
    
    @objc func loadReviews() {
        setUpRatings()
        
        self.reviewsWithText = recipeDetailVC!.reviews.filter { $0.text != nil }
        
        reviewsTableView.reloadData()
        
        if recipeDetailVC!.didSubmitReview {
            //delegate?.scrollToBottom()
            
            recipeDetailVC?.didSubmitReview = false
        }
        
        if recipeDetailVC?.recipe?.tags != nil {
            tagsCollectionView.reloadData()
            let height = tagsCollectionView.collectionViewLayout.collectionViewContentSize.height
            tagsCollectionView.heightConstraint?.constant = height
        } else {
            tagsCollectionView.heightConstraint?.constant = 0
        }
        
        self.layoutIfNeeded()
        reviewsTableView.heightConstraint?.constant = reviewsTableView.contentSize.height + 24
        self.layoutIfNeeded()
        
        delegate?.resizeCollectionView(forHeight: self.scrollView.contentSize.height)
    }
    
    @objc func refreshUserRating() {
        FirebaseController.shared.fetchUserReview(forRecipeID: recipeID) { (review) in
            guard let review = review else { return }
            self.review = review
        }
        
        if let hasCooked = recipeDetailVC?.recipe?.hasCooked, hasCooked {
            self.ratingsView.errorText.isHidden = true
            self.ratingsView.tapToRateLabel.isHidden = false
            self.ratingsView.ratingControl.isHidden = false
            self.writeReviewButton.isHidden = false
        } else {
            self.ratingsView.errorText.isHidden = false
            self.ratingsView.tapToRateLabel.isHidden = true
            self.ratingsView.ratingControl.isHidden = true
            self.writeReviewButton.isHidden = true
        }
    }
    
    func setUpRatings() {
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
    

    
    @objc func writeReviewButtonTapped() {
        delegate?.presentComposeReviewView()
    }
    
    // review: uid, user, title, text, rating, commentIDs, recipeID
    // comment: uid, user, text, reviewID
    // firebase
    //    recipes > recipeID > reviews > reviewID
    //    reviews > reviewID > info
    //    users > userID > reviewedRecipes > recipeID = reviewID
    // collectionview of reviews
    //     if a Review of a reviewCell has comments => insert a new commentCell below that reviewCell for each comment of the review
    //                                              => insert a new commentCollection below that reviewCell that has a commentCell for each comment
    
    var longString = "start ––– Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ––– end"
    
    var oneLineHeight: CGFloat {
        return 54.0
    }
    
    var longTagIndex: Int {
        return 1
    }
}

extension AboutCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let tags = recipeDetailVC?.recipe?.tags {
            return tags.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
        
        guard let tags = recipeDetailVC?.recipe?.tags else { return UICollectionViewCell() }
        
        let tag = tags[indexPath.item].rawValue
        
        let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: UIColor.white])
        cell.tagLabel.attributedText = attributedString
        cell.isSelected = true
        cell.setUpViews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return adaptConstant(12)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let tags = recipeDetailVC?.recipe?.tags else { return CGSize.zero }
        
        let tag = tags[indexPath.item].rawValue
        
        let attributedString = NSAttributedString(string: tag, attributes: [NSAttributedStringKey.font: UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!, NSAttributedStringKey.foregroundColor: UIColor.white])
        return CGSize(width: attributedString.size().width + adaptConstant(24), height: adaptConstant(27))
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
    func resizeCollectionView(forHeight height: CGFloat)
    func scrollToBottom()
}
