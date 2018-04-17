//
//  AccountAccessVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/6/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia
import Hero
import FacebookCore
import FacebookLogin
import Firebase
import SVProgressHUD

class AccountAccessVC: UIViewController {

    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backgroundImage")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "tasty traveler"
        label.textColor = UIColor.white
        label.heroModifiers = [.fade, .translate(y: -200)]
        return label
    }()
    
    lazy var onboardingCollectionVC: OnboardingCollectionVC = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let vc = OnboardingCollectionVC(collectionViewLayout: layout)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        return vc
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        return pageControl
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let shadowView = UIView()
        //shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 10
        
        shadowView.sv(view)
        view.followEdges(shadowView)
        shadowView.heroModifiers = [.fade, .translate(y: 200)]
        
        return shadowView
    }()
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        
        let shadowView = UIView()
        //shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 10
        
        shadowView.sv(view)
        view.followEdges(shadowView)
        shadowView.alpha = 0
        shadowView.heroID = "cardView"
        return shadowView
    }()
    
    lazy var emailSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "signUpButton"), for: .normal)
        button.addTarget(self, action: #selector(emailSignUpButtonTapped), for: .touchUpInside)
        let icon = UIImageView(image: #imageLiteral(resourceName: "emailIcon"))
        let iconWidth = self.view.frame.height * 0.020989505
        let iconHeight = self.view.frame.height * 0.016491754
        icon.width(iconWidth)
        icon.height(iconHeight)
        
        let label = UILabel()
        label.text = "SIGN UP"
        let fontSize = self.view.frame.height * 0.021
        label.font = UIFont(name: "ProximaNova-SemiBold", size: fontSize)
        label.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        button.sv(stackView)
        stackView.centerInContainer()
        return button
    }()
    
    lazy var facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "facebookButton"), for: .normal)
        let icon = UIImageView(image: #imageLiteral(resourceName: "facebookIcon"))
        let iconWidth = self.view.frame.height * 0.020989505
        let iconHeight = self.view.frame.height * 0.022488756
        icon.width(iconWidth)
        icon.height(iconHeight)
        button.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        let label = UILabel()
        label.text = "CONNECT"
        let fontSize = self.view.frame.height * 0.021
        label.font = UIFont(name: "ProximaNova-SemiBold", size: fontSize)
        label.textColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.isUserInteractionEnabled = false
        
        button.sv(stackView)
        stackView.centerInContainer()
        return button
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitleString = NSString(string: "Already have an account?  Sign In")
        let range = buttonTitleString.range(of: "Sign In")
        let fontSize = self.view.frame.height * 0.0245
        let attributedString = NSMutableAttributedString(string: buttonTitleString as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-Regular", size: fontSize)!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor(hexString: "6d6d6d")])
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont(name: "ProximaNova-Bold", size: fontSize)!,
                                        NSAttributedStringKey.foregroundColor : UIColor(hexString: "6d6d6d")], range: range)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        SVProgressHUD.setDefaultMaskType(.black)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpViews() {
        
        
        let stackView = UIStackView(arrangedSubviews: [emailSignUpButton, facebookButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        self.view.sv(
            backgroundView,
            titleLabel,
            onboardingCollectionVC.view,
            pageControl,
            cardView,
            bottomView.sv(
                stackView,
                signInButton
            )
        )
        
        backgroundView.fillContainer()
        
        // Title label
        let fontSize = self.view.frame.height * 0.068965517
        let spacing = self.view.frame.height * 0.056971514
        titleLabel.font = UIFont(name: "ProximaNova-Bold", size: fontSize)
        titleLabel.top(spacing)
        titleLabel.centerHorizontally()
        
        // Onboarding Collection View
        onboardingCollectionVC.view.backgroundColor = .clear
        onboardingCollectionVC.collectionView?.backgroundColor = .clear
        onboardingCollectionVC.view.Top == titleLabel.Bottom + 34
        onboardingCollectionVC.view.fillHorizontally()
        onboardingCollectionVC.view.Bottom == bottomView.Top
        pageControl.Bottom == onboardingCollectionVC.view.Bottom - spacing
        pageControl.centerHorizontally()
        
        // Bottom View
        bottomView.height(22%)
        bottomView.left(3.7%)
        bottomView.right(3.7%)
        bottomView.bottom(0)
        
        cardView.followEdges(bottomView)
        
        // Email Sign Up Button
        equal(widths: emailSignUpButton, facebookButton)
        stackView.top(27%)
        stackView.left(6.9%)
        stackView.right(6.9%)
        stackView.height(34%)
        stackView.centerHorizontally()
        
        signInButton.centerHorizontally()
        signInButton.Top == stackView.Bottom
        signInButton.bottom(0)
    }
    
    @objc func signInButtonTapped() {
        let signInVC = SignInVC()
        signInVC.isHeroEnabled = true
        signInVC.view.heroModifiers = [.fade]
        self.present(signInVC, animated: true, completion: nil)
    }
    
    @objc func emailSignUpButtonTapped() {
        let signUpVC = SignUpVC()
        signUpVC.isHeroEnabled = true
        signUpVC.view.heroModifiers = [.fade]
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logIn(readPermissions: [.publicProfile, .userFriends], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                
                SVProgressHUD.show()
                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error)
                        SVProgressHUD.dismiss()
                        return
                    }
                    if let user = user {
                        FirebaseController.shared.isUsernameStored(uid: user.uid, completion: { (result) in
                            SVProgressHUD.dismiss()
                            if result {
                                let mainTabBarController = MainTabBarController()
                                self.present(mainTabBarController, animated: true, completion: nil)
                                print("User: \(user)")
                            } else {
                                // NEW ACCOUNT USING FACEBOOK
                                let signUpVC = SignUpVC()
                                signUpVC.isFromFacebookLogin = true
                                signUpVC.isHeroEnabled = true
                                signUpVC.view.heroModifiers = [.fade]
                                self.present(signUpVC, animated: true, completion: nil)
                            }
                        })
                    } else {
                        print("Could not log in using Facebook.")
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    print("successfully signed in using firebase")
                })
            }
        }
    }
}
