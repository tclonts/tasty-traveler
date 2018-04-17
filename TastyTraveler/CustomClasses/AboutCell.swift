//
//  AboutCell.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/29/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class InfoBox: UIView {
    
    let infoImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        sv(infoImageView, infoLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AboutCell: BaseCell {
    
    let scrollView = UIScrollView()
    
    let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F8F8F8")
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
        label.text = "This is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description.his is an example of a description."
        return label
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        infoView.sv(servingsInfoBox, timeInfoBox, difficultyInfoBox)
        
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(descriptionText)
        descriptionStackView.axis = .vertical
        descriptionStackView.spacing = adaptConstant(18)
        
        let stackView = UIStackView(arrangedSubviews: [infoView, descriptionStackView])
        
        let margin = adaptConstant(16)
        
        scrollView.sv(stackView)
        
        stackView.fillContainer()
        stackView.Width == scrollView.Width
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = adaptConstant(27)
        descriptionStackView.left(25).right(25)
        
        
        sv(scrollView)
        
        scrollView.fillContainer()
        
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
        
        
        
        backgroundColor = .white
    }
}
