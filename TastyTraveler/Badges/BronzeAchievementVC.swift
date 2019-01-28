//
//  BadgeAchievementVC.swift
//  TastyTraveler
//
//  Created by Tyler Clonts on 9/14/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import SwiftySound

class BronzeAchievementVC: UIViewController {
    
    
    let backgroundView = UIView()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hooray!"
        label.font = ProximaNova.semibold.of(size: 20)
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
        label.text = "You recieved a bronze badge and 100 points!"
        label.font = ProximaNova.semibold.of(size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = Color.darkGrayText
        return label
    }()
    
    let hikerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "bronzeBadgePopUp")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var okayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Okay", for: .normal)
        button.titleLabel?.font = ProximaNova.semibold.of(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = adaptConstant(12)
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.backgroundColor = Color.primaryOrange
        button.addTarget(self, action: #selector(okayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func okayButtonTapped() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.backgroundView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
        }, completion: nil)
        
        self.emitter.birthRate = 0
        
        let when = DispatchTime.now() + 1.2
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            self.dismiss(animated: false, completion: nil)
            print("DISMISSED")
        })
        
    }
    
    func generateEmitterCells() -> [CAEmitterCell] {
        
        let red = makeEmitterCell(color: Color.Bronze)
        let green = makeEmitterCell(color: Color.Bronze)
        let blue = makeEmitterCell(color: Color.Bronze)
        let yellow = makeEmitterCell(color: Color.Bronze)
        
        return [red, green, blue, yellow]
    }
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 15
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 700
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        cell.contents = #imageLiteral(resourceName: "confettiParticle").cgImage
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = adaptConstant(12)
        backgroundView.clipsToBounds = true
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)
        backgroundView.layer.shadowRadius = 15
        backgroundView.layer.shadowOpacity = 0.15
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.masksToBounds = false
        
        setUpViews()
        
        self.backgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    func setUpViews() {
        self.view.sv(backgroundView)
        
        backgroundView.left(adaptConstant(50)).right(adaptConstant(50)).centerVertically()
        backgroundView.sv(titleLabel, horizontalRule, hikerImage, descriptionLabel, okayButton)
        
        titleLabel.top(adaptConstant(16)).centerHorizontally()
        
        horizontalRule.Top == titleLabel.Bottom + adaptConstant(16)
        horizontalRule.left(0).right(0)
        
        hikerImage.Top == descriptionLabel.Bottom + adaptConstant(30)
        hikerImage.left(adaptConstant(20)).right(adaptConstant(20)).height(adaptConstant(300))
        
        descriptionLabel.Top == horizontalRule.Bottom + adaptConstant(16)
        descriptionLabel.centerHorizontally().right(adaptConstant(20)).left(adaptConstant(20))
        
        okayButton.Top == hikerImage.Bottom + adaptConstant(30)
        okayButton.height(adaptConstant(50)).left(0).right(0).bottom(0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.backgroundView.transform = .identity
        }) { (completion) in
            
        }
    }
    
    let emitter = CAEmitterLayer()
    
    func show() {
        emitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        
        emitter.emitterCells = generateEmitterCells()
        
        self.view.layer.insertSublayer(emitter, at: 0)
        
        Sound.play(file: "tada.mp3")
    }
    
}
