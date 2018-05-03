//
//  CookedItAlertView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/30/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Cosmos
import Stevia
import Popover

class CookedItAlertView: UIViewController {
    
    let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0
        return view
    }()
    
    let backgroundView = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You cooked it!"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(20))
        label.textColor = Color.darkText
        return label
    }()
    
    let horizontalRule: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightGray
        view.height(1)
        return view
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "What did you think of this recipe?"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))
        label.textColor = Color.darkGrayText
        return label
    }()
    
    let ratingControl: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = true
        cosmosView.settings.fillMode = .full
        cosmosView.settings.starSize = 30
        cosmosView.settings.starMargin = 12
        cosmosView.settings.filledColor = Color.primaryOrange
        cosmosView.settings.emptyBorderColor = Color.primaryOrange
        cosmosView.settings.filledBorderColor = Color.primaryOrange
        return cosmosView
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setCustomTitle(string: "Done", font: ProximaNova.semibold.of(size: adaptConstant(18)), textColor: .white, for: .normal)
        button.backgroundColor = Color.primaryOrange
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var delegate: CookedItAlertViewDelegate?
    var rating: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = .clear
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = adaptConstant(12)
        backgroundView.clipsToBounds = true
        
        setUpViews()
        
        self.backgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showAlertView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 1
            self.backgroundView.transform = .identity
        }, completion: nil)
    }
    
    func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.overlayView.alpha = 0
            self.backgroundView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height - self.backgroundView.frame.height / 2)
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func doneButtonTapped() {
//        guard let rating = rating else { return }
//        delegate?.submitRating(rating)
//
        handleDismiss()
    }
    
    func setUpViews() {
        self.view.sv(overlayView, backgroundView)
        
        overlayView.fillContainer()
        backgroundView.left(adaptConstant(30)).right(adaptConstant(30)).centerVertically()
        
        backgroundView.sv(titleLabel, horizontalRule, descriptionLabel, ratingControl, doneButton)
        
        titleLabel.top(adaptConstant(16)).centerHorizontally()
        
        horizontalRule.Top == titleLabel.Bottom + adaptConstant(16)
        horizontalRule.left(0).right(0)
        
        descriptionLabel.Top == horizontalRule.Bottom + adaptConstant(25)
        descriptionLabel.centerHorizontally()
        
        ratingControl.Top == descriptionLabel.Bottom + adaptConstant(50)
        ratingControl.centerHorizontally()
        
        doneButton.Top == ratingControl.Bottom + adaptConstant(30)
        
        doneButton.height(adaptConstant(50)).left(0).right(0).bottom(0)
    }
}

protocol CookedItAlertViewDelegate: class {
    func submitRating(_: Int)
}
