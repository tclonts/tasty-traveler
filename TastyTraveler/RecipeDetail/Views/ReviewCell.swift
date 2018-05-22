//
//  ReviewCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Cosmos
import Stevia

class ReviewCell: UITableViewCell {
    
    var review: Review! {
        didSet {
            if let url = review.user.avatarURL {
                self.avatarImageView.loadImage(urlString: url, placeholder: #imageLiteral(resourceName: "avatar"))
            }
            
            if let title = review.title {
                self.titleLabel.text = title
            }
            
            if let text = review.text {
                self.reviewTextLabel.text = text
            }
            
            if let rating = review.rating {
                self.starRatingView.rating = Double(rating)
            }
            
            self.usernameLabel.text = review.user.username
            
            if let date = review.creationDate {
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                
                if Calendar.current.isDate(today, equalTo: date, toGranularity: .year) {
                    dateLabel.text = dateFormatter.string(from: date)
                } else {
                    dateLabel.text = dateFormatter.timeSince(from: date as NSDate, numericDates: true)
                }
            }
            
//            if review.commentsDictionary != nil {
//                fetchComments()
//            }
        }
    }
    
    lazy var reviewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F8F8FB")
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reviewTapped)))
        return view
    }()
    
    let avatarImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = adaptConstant(40) / 2
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.semibold.of(size: 16)
        label.textColor = Color.darkText
        return label
    }()
    
    let starRatingView: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = Double(adaptConstant(15))
        cosmosView.settings.starMargin = Double(adaptConstant(2))
        cosmosView.settings.filledColor = Color.primaryOrange
        cosmosView.settings.emptyBorderColor = Color.primaryOrange
        cosmosView.settings.filledBorderColor = Color.primaryOrange
        cosmosView.settings.textFont = ProximaNova.regular.of(size: 11)
        return cosmosView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 14)
        label.textColor = Color.gray
        label.textAlignment = .right
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = ProximaNova.regular.of(size: 14)
        label.textColor = Color.gray
        label.textAlignment = .right
        return label
    }()
    
    let reviewTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = ProximaNova.regular.of(size: 16)
        label.textColor = Color.darkText
        return label
    }()
    
//    lazy var commentsTableView: UITableView = {
//        let tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.isScrollEnabled = false
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 50
//        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
//        tableView.isHidden = true
//        tableView.backgroundColor = .white
//        tableView.separatorStyle = .none
//        return tableView
//    }()
    
    weak var reviewsTableView: UITableView?
    
//    var comments = [Comment]()
//
//    func fetchComments() {
//
//    }
    
    @objc func reviewTapped() {
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sv(reviewBackground.sv(avatarImageView, titleLabel, dateLabel, starRatingView, usernameLabel, reviewTextLabel))
        
        reviewBackground.top(0).left(0).right(0).bottom(12)
        
        let margin: CGFloat = adaptConstant(8)
        
        avatarImageView.top(adaptConstant(12)).left(adaptConstant(12)).height(adaptConstant(40)).width(adaptConstant(40))
        titleLabel.Left == avatarImageView.Right + margin
        titleLabel.top(adaptConstant(12))
        
        dateLabel.right(adaptConstant(14))
        dateLabel.CenterY == titleLabel.CenterY
        
        starRatingView.Left == avatarImageView.Right + margin
        starRatingView.Bottom == avatarImageView.Bottom
        
        usernameLabel.right(adaptConstant(14))
        usernameLabel.CenterY == starRatingView.CenterY
        
        reviewTextLabel.left(adaptConstant(12))
        reviewTextLabel.Top == starRatingView.Bottom + adaptConstant(16)
        reviewTextLabel.right(adaptConstant(12)).bottom(adaptConstant(12))
        
//        commentsTableView.Top == reviewBackground.Bottom + adaptConstant(12)
//        commentsTableView.left(adaptConstant(56)).right(0).bottom(adaptConstant(14))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //reviewBackground.Bottom == reviewTextLabel.Bottom + adaptConstant(12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//extension ReviewCell: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return comments.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
//
//        return cell
//    }
//}

