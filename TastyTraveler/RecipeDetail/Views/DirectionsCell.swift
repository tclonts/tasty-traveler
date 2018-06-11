//
//  DirectionsCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/29/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class DirectionsCell: BaseCell, UITableViewDelegate, UITableViewDataSource {
    
    var steps = [String]()
    var hasVideo = false
    var videoURL: String?
    var thumbnailURL: String?
    var recipeDetailVC: RecipeDetailVC?
    var delegate: AboutCellDelegate?
    
    let videoHeaderView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Video"
        
        view.sv(label)
        label.top(adaptConstant(27)).left(0).right(0).bottom(adaptConstant(18))
        
        return view
    }()
    
    let stepsHeaderView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))
        label.textColor = Color.darkText
        label.text = "Steps"
        
        view.sv(label)
        label.top(adaptConstant(27)).left(0).right(0).bottom(adaptConstant(18))
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .grouped)
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.estimatedRowHeight = adaptConstant(40)
        tv.rowHeight = UITableViewAutomaticDimension
        tv.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        tv.estimatedSectionHeaderHeight = 30
        tv.backgroundColor = .white
        tv.allowsMultipleSelection = true
        tv.register(StepCell.self, forCellReuseIdentifier: "stepCell")
        tv.register(VideoCell.self, forCellReuseIdentifier: "videoCell")
        return tv
    }()
    
    var sectionHeaders = [UIView]()
    
    override func setUpViews() {
        super.setUpViews()
        
        sectionHeaders = [videoHeaderView, stepsHeaderView]
        
        sv(tableView)
        
        tableView.top(0).left(adaptConstant(25)).right(adaptConstant(25)).bottom(0)
        
        backgroundColor = .white
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasVideo ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if hasVideo {
            return sectionHeaders[section]
        } else {
            return sectionHeaders[1]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasVideo {
            switch section {
            case 0:
                return 1
            case 1:
                return steps.count
            default:
                return 0
            }
        } else {
            return steps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasVideo {
            if indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as? VideoCell {
                    guard let thumbnailURL = thumbnailURL else { return UITableViewCell() }
                    cell.thumbnailURL = thumbnailURL
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath) as? StepCell {
            let step = steps[indexPath.row]
            cell.label.text = "\(indexPath.row + 1).  \(step)"
            cell.selectionStyle = .none
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.resizeCollectionView(forHeight: self.tableView.contentSize.height, cell: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? VideoCell {
            tableView.deselectRow(at: indexPath, animated: false)
            self.recipeDetailVC?.playVideo()
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? StepCell {
            let attributes: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                 NSAttributedStringKey.foregroundColor : Color.lightGray,
                 NSAttributedStringKey.strikethroughStyle: 1]
            
            let text = cell.label.text!
            cell.label.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? StepCell {
            let attributes: [NSAttributedStringKey: Any] =
                [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                 NSAttributedStringKey.foregroundColor : Color.darkGrayText,
                 NSAttributedStringKey.strikethroughStyle: 0]
            
            let text = cell.label.text!
            cell.label.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
    
    func playVideo() {
        self.recipeDetailVC?.playVideo()
    }
}

class VideoCell: UITableViewCell {
    var thumbnailURL: String? {
        didSet {
            tutorialVideoImageView.loadImage(urlString: thumbnailURL!, placeholder: nil)
        }
    }
    
    lazy var tutorialVideoImageView: CustomImageView = {
        let imageView = CustomImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = adaptConstant(10)
        
        let playButtonImage = UIImageView()
        playButtonImage.image = #imageLiteral(resourceName: "playButton")
        
        imageView.sv(playButtonImage)
        
        playButtonImage.width(adaptConstant(36)).height(adaptConstant(36))
        playButtonImage.centerInContainer()
        
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sv(tutorialVideoImageView)
        
        tutorialVideoImageView.fillContainer()
        tutorialVideoImageView.Height == tutorialVideoImageView.Width * 0.75
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StepCell: UITableViewCell {
    let label = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        label.numberOfLines = 0
        label.textColor = Color.darkGrayText
        
        sv(label)
        
        label.top(adaptConstant(8)).bottom(adaptConstant(8)).left(0).right(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
