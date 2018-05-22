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
    
//    lazy var onboardingCollectionVC: OnboardingCollectionVC = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        let vc = OnboardingCollectionVC(collectionViewLayout: layout)
//        addChildViewController(vc)
//        vc.didMove(toParentViewController: self)
//        return vc
//    }()
    
//    let pageControl: UIPageControl = {
//        let pageControl = UIPageControl()
//        pageControl.numberOfPages = 3
//        pageControl.isUserInteractionEnabled = false
//        return pageControl
//    }()
    
    let onboardingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let earthImageView = UIImageView(image: #imageLiteral(resourceName: "earth"))
        earthImageView.height(adaptConstant(183)).width(adaptConstant(183))
        
        let circleImageView = UIImageView(image: #imageLiteral(resourceName: "circle"))
        circleImageView.height(adaptConstant(217)).width(adaptConstant(217))
        
        let magnifyingGlassImageView = UIImageView(image: #imageLiteral(resourceName: "magnifyingGlass"))
        magnifyingGlassImageView.height(adaptConstant(119)).width(adaptConstant(121))
        
        let label = UILabel()
        label.text = "Discover authentic recipes from around the world."
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(20))
        label.alpha = 0.85
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        
        view.sv(earthImageView, circleImageView, magnifyingGlassImageView, label)
        
        earthImageView.top(adaptConstant(18))
        earthImageView.centerHorizontally()
        
        circleImageView.top(0)
        circleImageView.centerHorizontally()
        
        magnifyingGlassImageView.Bottom == earthImageView.Bottom
        magnifyingGlassImageView.Left == circleImageView.CenterX
        
        label.Top == circleImageView.Bottom + adaptConstant(40)
        label.left(0).right(0).bottom(0)
        label.centerHorizontally()
        
        return view
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = adaptConstant(17)
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
        view.layer.cornerRadius = adaptConstant(17)
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
        icon.width(adaptConstant(14))
        icon.height(adaptConstant(11))
        
        let label = UILabel()
        label.text = "SIGN UP"
        let fontSize = adaptConstant(14)
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
        icon.width(adaptConstant(14))
        icon.height(adaptConstant(15))
        button.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        let label = UILabel()
        label.text = "CONNECT"
        let fontSize = adaptConstant(14)
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
        let fontSize = adaptConstant(16)
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
            //onboardingCollectionVC.view,
            //pageControl,
            onboardingView,
            cardView,
            bottomView.sv(
                stackView,
                signInButton
            )
        )
        
        backgroundView.fillContainer()
        
        // Title label
        let fontSize = adaptConstant(45)
//        let spacing = adaptConstant(38)
        titleLabel.font = UIFont(name: "ProximaNova-Bold", size: fontSize)
        titleLabel.Bottom == onboardingView.Top - adaptConstant(40)
        titleLabel.centerHorizontally()
        
        // Onboarding Collection View
//        onboardingCollectionVC.accountAccessVC = self
//        onboardingCollectionVC.view.backgroundColor = .clear
//        onboardingCollectionVC.collectionView?.backgroundColor = .clear
//        onboardingCollectionVC.view.Top == titleLabel.Bottom + adaptConstant(34)
//        onboardingCollectionVC.view.fillHorizontally()
//        onboardingCollectionVC.view.Bottom == bottomView.Top
//        pageControl.Bottom == onboardingCollectionVC.view.Bottom - spacing
//        pageControl.centerHorizontally()
        if screenHeight == iPhoneXScreenHeight {
            onboardingView.centerInContainer()
        } else {
            onboardingView.Bottom == bottomView.Top - adaptConstant(60)
        }
        onboardingView.left(adaptConstant(60)).right(adaptConstant(60))
        
        // Bottom View
        var bottomHeight = adaptConstant(146)
        if screenHeight == iPhoneXScreenHeight { bottomHeight += self.view.safeAreaInsets.bottom + 12 }
        bottomView.height(bottomHeight)
        bottomView.left(adaptConstant(20))
        bottomView.right(adaptConstant(20))
        bottomView.bottom(0)
        
        cardView.followEdges(bottomView)
        
        // Email Sign Up Button
        equal(widths: emailSignUpButton, facebookButton)
        stackView.top(adaptConstant(38))
        stackView.left(adaptConstant(20))
        stackView.right(adaptConstant(20))
        stackView.height(adaptConstant(50))
        stackView.centerHorizontally()
        
        signInButton.centerHorizontally()
        if screenHeight == iPhoneXScreenHeight {
            signInButton.Top == stackView.Bottom + 12
        } else {
            signInButton.Top == stackView.Bottom
            signInButton.bottom(0)
        }
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
    
    func verifyUserAndLogin(user: User) {
        
        FirebaseController.shared.isUsernameStored(uid: user.uid, completion: { (result) in
            SVProgressHUD.dismiss()
            if result {
                let mainTabBarController = MainTabBarController()
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                
                appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
                UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                    appDelegate.window?.rootViewController = mainTabBarController
                }, completion: nil)
                
            } else {
                let signUpVC = SignUpVC()
                signUpVC.isFromFacebookLogin = true
                signUpVC.isHeroEnabled = true
                signUpVC.view.heroModifiers = [.fade]
                self.present(signUpVC, animated: true, completion: nil)
            }
        })
        print("successfully signed in using firebase")
    }
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        loginManager.loginBehavior = .native
        loginManager.logIn(readPermissions: [.email], viewController: self) { (loginResult) in
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
                        if (error as NSError).code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
                            
                            if let userEmail = (error as NSError).userInfo[AuthErrorUserInfoEmailKey] as? String {
                                let ac = UIAlertController(title: "Existing Account", message: "There is an account registered to the email associated with your Facebook account. Enter your password to merge accounts.", preferredStyle: .alert)
                                ac.addTextField(configurationHandler: { (textField) in
                                    textField.placeholder = "Enter password"
                                    textField.isSecureTextEntry = true
                                })
                                ac.addAction(UIAlertAction(title: "Merge", style: .default, handler: { (_) in
                                    guard let text = ac.textFields![0].text else { return }
                                    
                                    SVProgressHUD.show()
                                    
                                    let emailCredential = EmailAuthProvider.credential(withEmail: userEmail, password: text)
                                    
                                    Auth.auth().signIn(with: emailCredential, completion: { (user, error) in
                                        if let error = error {
                                            print(error)
                                            SVProgressHUD.showError(withStatus: "Incorrect password")
                                            return
                                        }
                                        
                                        user!.link(with: credential, completion: { (user, error) in
                                            if let error = error {
                                                print(error)
                                                SVProgressHUD.dismiss()
                                                return
                                            }
                                            
                                            if let user = user {
                                                self.verifyUserAndLogin(user: user)
                                            }
                                        })
                                    })
                                }))
                                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                self.present(ac, animated: true, completion: nil)
                            }
                        }
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    if let user = user {
                        
                        self.verifyUserAndLogin(user: user)
                    }
                })
            }
        }
    }
}
