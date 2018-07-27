//
//  SignUpVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/12/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Hero
import Stevia
import Firebase
import UserNotifications
import FacebookCore

class SignUpVC: UIViewController, UITextFieldDelegate {

    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backgroundImage")
        return imageView
    }()
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = adaptConstant(15)
        view.layer.masksToBounds = true
        
        let shadowView = UIView()
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        shadowView.layer.shadowRadius = 10
        
        shadowView.sv(view)
        view.followEdges(shadowView)
        return shadowView
    }()
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome!"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(28))
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let welcomeMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backArrow"), for: .normal)
        button.heroID = "backButton"
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let usernamePlaceholder: UILabel = {
        let label = UILabel()
        label.text = "USERNAME"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = UIColor(hexString: "C7C7CD")
        return label
    }()
    
    lazy var usernameTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.borderStyle = .none
        textField.returnKeyType = .next
        textField.backgroundColor = .clear
        textField.tag = 0
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
    }()
    
    let usernameError: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(12))
        label.textColor = .red
        label.alpha = 0
        return label
    }()
    
    let emailPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "EMAIL"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = UIColor(hexString: "C7C7CD")
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.borderStyle = .none
        textField.returnKeyType = .next
        textField.backgroundColor = .clear
        textField.keyboardType = .emailAddress
        textField.tag = 1
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
    }()
    
    let emailError: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(12))
        label.textColor = .red
        label.alpha = 0
        return label
    }()
    
    let passwordPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "PASSWORD"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))
        label.textColor = UIColor(hexString: "C7C7CD")
        return label
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.keyboardType = .default
        textField.backgroundColor = .clear
        textField.tag = 2
        textField.returnKeyType = .done
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
    }()
    
    let passwordError: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(12))
        label.textColor = .red
        label.alpha = 0
        return label
    }()
    
    let usernameTextFieldBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "DDDDDD")
        view.height(1)
        return view
    }()
    
    let emailTextFieldBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "DDDDDD")
        view.height(1)
        return view
    }()
    
    let passwordTextFieldBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "DDDDDD")
        view.height(1)
        return view
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedString = NSMutableAttributedString(string: "SIGN UP" as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor.white])
        button.setAttributedTitle(attributedString, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = button.frame.width / 2
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedString = NSMutableAttributedString(string: "Forgot password?" as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor(hexString: "#FF6322")])
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitleString = NSString(string: "Already have an account?  Sign In")
        let range = buttonTitleString.range(of: "Sign In")
        let attributedString = NSMutableAttributedString(string: buttonTitleString as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.8)])
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
                                        NSAttributedStringKey.foregroundColor : UIColor.white], range: range)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        return recognizer
    }()
    
    // MARK: - Constraints
    lazy var centerXConstraint = constraint(item: cardView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
    lazy var centerYConstraint = constraint(item: cardView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var cardViewTopConstraint = constraint(item: cardView, attribute: .top, relatedBy: .equal, toItem: backButton, attribute: .bottom, multiplier: 1, constant: adaptConstant(27))
    lazy var usernamePlaceholderConstraint = constraint(item: usernamePlaceholder, attribute: .centerY, relatedBy: .equal, toItem: usernameTextField, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var usernamePlaceholderActiveConstraint = constraint(item: usernamePlaceholder, attribute: .bottom, relatedBy: .equal, toItem: usernameTextField, attribute: .top, multiplier: 1, constant: -adaptConstant(7))
    lazy var emailPlaceholderConstraint = constraint(item: emailPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: emailTextField, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var emailPlaceholderActiveConstraint = constraint(item: emailPlaceholder, attribute: .bottom, relatedBy: .equal, toItem: emailTextField, attribute: .top, multiplier: 1, constant: -adaptConstant(7))
    lazy var passwordPlaceholderConstraint = constraint(item: passwordPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: passwordTextField, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var passwordPlaceholderActiveConstraint = constraint(item: passwordPlaceholder, attribute: .bottom, relatedBy: .equal, toItem: passwordTextField, attribute: .top, multiplier: 1, constant: -adaptConstant(7))
    
    var isFromSignInVC = false
    var isWaitingForKeyboardDismissal = false
    var isTransitioningToSignInVC = false
    var isFromFacebookLogin = false
    var needsUsername = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
        
        if needsUsername {
            self.welcomeLabel.text = "Finish signing up with Facebook"
            
            self.backButton.isHidden = true
            let attributedString = NSMutableAttributedString(string: "Back to main menu",
                                                             attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                                                                          NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.8)])
            self.signInButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signUpButton.applyGradient(colors: [UIColor(hexString: "#FF8C2B").cgColor, UIColor(hexString: "#FF6322").cgColor])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpViews() {
        if isFromFacebookLogin {
            view.sv(
                backgroundView,
                welcomeMessageView.sv(welcomeLabel),
                backButton,
                cardView.sv(
                    usernamePlaceholder,
                    usernameTextField,
                    usernameTextFieldBottomBorder,
                    usernameError,
                    signUpButton
                ),
                signInButton
            )
        } else {
            view.sv(
                backgroundView,
                welcomeMessageView.sv(welcomeLabel),
                backButton,
                cardView.sv(
                    usernamePlaceholder,
                    usernameTextField,
                    usernameTextFieldBottomBorder,
                    usernameError,
                    emailPlaceholder,
                    emailTextField,
                    emailTextFieldBottomBorder,
                    emailError,
                    passwordPlaceholder,
                    passwordTextField,
                    passwordTextFieldBottomBorder,
                    passwordError,
                    signUpButton
                ),
                signInButton
            )
        }
        
        applyConstraints()
        applyHeroModifiers()
    }
    
    func applyConstraints() {
        backgroundView.fillContainer()
        backButton.top(adaptConstant(45))
        backButton.left(adaptConstant(10))
        
        cardView.left(adaptConstant(12)).right(adaptConstant(12))
        self.view.addConstraints([centerXConstraint, centerYConstraint])
        
        welcomeMessageView.top(adaptConstant(18)).left(0).right(0)
        welcomeMessageView.Bottom == cardView.Top
        welcomeLabel.centerVertically().left(adaptConstant(24)).right(adaptConstant(24))
        
        usernameTextField.left(adaptConstant(18)).right(adaptConstant(18)).top(adaptConstant(45))
        equal(widths: [usernameTextField, usernameTextFieldBottomBorder])
        usernameTextFieldBottomBorder.Top == usernameTextField.Bottom + adaptConstant(7)
        usernameTextFieldBottomBorder.centerHorizontally()
        usernameError.Top == usernameTextFieldBottomBorder.Bottom + adaptConstant(3)
        usernameError.right(adaptConstant(18))

        usernamePlaceholder.Left == usernameTextField.Left
        self.view.addConstraint(usernamePlaceholderConstraint)
        
        if isFromFacebookLogin {
            
            signUpButton.Top == usernameTextFieldBottomBorder.Bottom + adaptConstant(45)
        } else {
            emailTextField.left(adaptConstant(18)).right(adaptConstant(18))
            emailTextField.Top == usernameTextFieldBottomBorder.Bottom + adaptConstant(45)
            equal(widths: [emailTextField, emailTextFieldBottomBorder])
            emailTextFieldBottomBorder.Top == emailTextField.Bottom + adaptConstant(7)
            emailTextFieldBottomBorder.centerHorizontally()
            emailError.Top == emailTextFieldBottomBorder.Bottom + adaptConstant(3)
            emailError.right(adaptConstant(18))
            
            emailPlaceholder.Left == emailTextField.Left
            
            passwordTextField.left(adaptConstant(18)).right(adaptConstant(18))
            passwordTextField.Top == emailTextFieldBottomBorder.Bottom + adaptConstant(45)
            equal(widths: [passwordTextField, passwordTextFieldBottomBorder])
            passwordTextFieldBottomBorder.Top == passwordTextField.Bottom + adaptConstant(7)
            passwordTextFieldBottomBorder.centerHorizontally()
            passwordError.Top == passwordTextFieldBottomBorder.Bottom + adaptConstant(3)
            passwordError.right(adaptConstant(18))
            
            passwordPlaceholder.Left == passwordTextField.Left
            
            self.view.addConstraints([emailPlaceholderConstraint, passwordPlaceholderConstraint])
            
            signUpButton.Top == passwordTextFieldBottomBorder.Bottom + adaptConstant(45)
        }
        
        signUpButton.height(adaptConstant(45))
        signUpButton.left(adaptConstant(18)).right(adaptConstant(18)).bottom(adaptConstant(22))
        
        signInButton.Top == cardView.Bottom + adaptConstant(18)
        signInButton.centerHorizontally()
    }
    
    func applyHeroModifiers() {
        if isTransitioningToSignInVC {
            let fadeLeftModifiers: [HeroModifier] = [.duration(0.3), .forceNonFade, .translate(x: -self.view.frame.width)]
            welcomeLabel.heroModifiers = [.fade, .translate(y: -adaptConstant(45))]
            signUpButton.heroModifiers = [.fade, .translate(y: -adaptConstant(45))]
            cardView.heroModifiers = fadeLeftModifiers
        } else if isFromSignInVC {
            let modifiers: [HeroModifier] = [.duration(0.3), .forceNonFade, .translate(x: self.view.frame.width)]
            welcomeLabel.heroModifiers = [.fade, .translate(y: adaptConstant(45))]
            signUpButton.heroModifiers = [.fade, .translate(y: adaptConstant(45))]
            cardView.heroModifiers = modifiers
        } else {
            let modifiers: [HeroModifier] = [.fade, .translate(y: adaptConstant(180))]
            welcomeLabel.heroModifiers = modifiers
            signUpButton.heroModifiers = modifiers
            cardView.heroModifiers = modifiers
        }
    }
    
    @objc func signInButtonTapped() {
        if needsUsername {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromTop, animations: {
                appDelegate.window?.rootViewController = AccountAccessVC()
            }, completion: nil)
        } else {
            let signInVC = SignInVC()
            signInVC.isHeroEnabled = true
            self.isTransitioningToSignInVC = true
            signInVC.isFromSignUpVC = true
            applyHeroModifiers()
            self.present(signInVC, animated: true, completion: nil)
        }
    }
    
    @objc func signUpButtonTapped() {
        guard usernameTextField.text != "" else {
            showError(type: .username, message: "Username is empty.")
            return
        }
        
        self.usernameTextField.text = self.usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let usernameText = usernameTextField.text else { return }
        
        guard usernameText != "" else {
            print("Username field is empty.")
            showError(type: .username, message: "Username is empty.")
            return
        }
        
        guard usernameText.count <= 24 else { print("Username is too long."); showError(type: .username, message: "Username is too long."); return }
        
        if !isFromFacebookLogin {
            
            // validate email
            guard let emailText = emailTextField.text else { return }
            guard emailText != "" else {
                showError(type: .email, message: "Email is empty.")
                return
            }
            
            let validator = Validator()
            guard let email = validator.validate(email: emailText) else {
                print("Email is invalid.")
                showError(type: .email, message: "Email is invalid.")
                return
            }
            
            Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if providers != nil {
                    self.showError(type: .email, message: "Email is already in use.")
                    
                } else {
                    guard let password = self.passwordTextField.text else { return }
                    guard password != "" else {
                        self.showError(type: .password, message: "Password is empty.")
                        return
                    }
                    
                    FirebaseController.shared.verifyUniqueUsername(usernameText, completion: { (isUnique) in
                        if isUnique {
                            
                            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                guard let uid = user?.uid else { return }
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    FirebaseController.shared.ref.child("users").child(uid).child("badgeCount").setValue(0)
                                    FirebaseController.shared.ref.child("users").child(uid).child("unreadMessagesCount").setValue(0)
                                    FirebaseController.shared.storeUsername(usernameText, uid: uid, completion: { (_) in
                                        self.sendWelcomeMessage()
                                    })
                                    //UserDefaults.standard.set(false, forKey: "firstRecipeUploaded")
                                                                    
                                    self.view.endEditing(true)
                                    let mainTabBarController = MainTabBarController()
                                    
                                    let registrationEvent = AppEvent.completedRegistration(registrationMethod: "email", valueToSum: 1.0, extraParameters: ["userID": uid])
                                    AppEventsLogger.log(registrationEvent)
                                    
                                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                    
                                    appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                                    
                                    UserDefaults.standard.set(false, forKey: "isBrowsing")
                                    
                                    UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                                        appDelegate.window?.rootViewController = mainTabBarController
                                    }, completion: nil)
                                }
                            })
                        } else {
                            print("Username is already taken")
                            self.showError(type: .username, message: "Username is already taken.")
                        }
                    })
                }
            }
        } else {
            guard let uid = Auth.auth().currentUser?.uid else { print("No user id for Facebook user."); return }
            FirebaseController.shared.verifyUniqueUsername(usernameText, completion: { (isUnique) in
                if isUnique {
                    FirebaseController.shared.ref.child("users").child(uid).child("badgeCount").setValue(0)
                    FirebaseController.shared.ref.child("users").child(uid).child("unreadMessagesCount").setValue(0)
                    FirebaseController.shared.storeUsername(usernameText, uid: uid, completion: { (_) in
                        self.sendWelcomeMessage()
                    })
                    //UserDefaults.standard.set(false, forKey: "firstRecipeUploaded")
                    
                    self.view.endEditing(true)
                    let mainTabBarController = MainTabBarController()
                    
                    let registrationEvent = AppEvent.completedRegistration(registrationMethod: "facebook", valueToSum: 1.0, extraParameters: ["userID": uid])
                    AppEventsLogger.log(registrationEvent)
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    
                    UserDefaults.standard.set(false, forKey: "isBrowsing")
                    
                    appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                    UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                        appDelegate.window?.rootViewController = mainTabBarController
                    }, completion: nil)
                } else {
                    print("Username is already taken")
                    self.showError(type: .username, message: "Username is already taken.")
                }
            })
        }
    }
    
    func sendWelcomeMessage() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let username = Auth.auth().currentUser?.displayName else { return }
        
        let ref = FirebaseController.shared.ref.child("messages")
        let childRef = ref.childByAutoId()
        let toID = userID
        let fromID = "Zzk10HjWRWOXlBnCmbK2STYBj2N2"// Tasty Traveler account uid
        let timestamp = Date().timeIntervalSince1970
        
        let values: [String:Any] = ["toID": toID,
                                    "fromID": fromID,
                                    "timestamp": timestamp,
                                    "text": "Hello \(username), thank you for joining Tasty Traveler, a place where people can cook, share, and communicate with one another about everyone's favorite thing...food. \n\nWe want to let you know that Tasty Traveler will never flood your email inbox with spam mail, and will never use your info for anything outside of Tasty Traveler. \n\nWe welcome and encourage you to be an active member of this community and share your talent with the world! By contributing recipes or cooking recipes created by others, you are helping to build a better community for all of us here. \n\nAlso, this communication portal is for you to give us your feedback and send us any ideas you have about how to improve the overall experience of Tasty Traveler. \n\nIf you have any questions, please ask them here. We'd love to hear from you. \n\nThank you and have fun discovering and cooking delicious recipes.",
            "unread": true]
        
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error { print(error); return }
            
            let userMessagesRef = FirebaseController.shared.ref.child("userMessages").child(fromID).child(toID)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID: true])
            
            let recipientUserMessagesRef = FirebaseController.shared.ref.child("userMessages").child(toID).child(fromID)
            recipientUserMessagesRef.updateChildValues([messageID: true])
        }
    }
    
    func scheduleNotification() {
        // Create a notification to be triggered 48 hours later
        let currentDate = Date()
        let date = Calendar.current.date(byAdding: .hour, value: 2, to: currentDate)
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        guard let username = Auth.auth().currentUser?.displayName else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Welcome, \(username)"
        content.body = "Thank you for being a part of the Tasty Traveler community. We've sent you a message in-app. Go check it out!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "welcomeNotification"
        
        let request = UNNotificationRequest(identifier: "welcomeNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("Error: \(error)")
            }
            
            UserDefaults.standard.setValue(date, forKey: "scheduledDate")
        })
    }
    
    func showError(type: ValidationError, message: String) {
        var errorToShow: UILabel
        
        switch type {
        case .username:
            errorToShow = self.usernameError
        case .email:
            errorToShow = self.emailError
        case .password:
            errorToShow = self.passwordError
        }
        
        errorToShow.text = message
        
        UIView.animate(withDuration: 0.2) {
            errorToShow.alpha = 1
        }
    }
    
    func hideError(_ type: ValidationError) {
        var errorToHide: UILabel
        
        switch type {
        case .username:
            errorToHide = self.usernameError
        case .email:
            errorToHide = self.emailError
        case .password:
            errorToHide = self.passwordError
        }
        
        UIView.animate(withDuration: 0.2) {
            errorToHide.alpha = 0
        }
    }
    
    @objc func backButtonTapped() {
        let fadeInUpModifiers: [HeroModifier] = [.fade, .translate(y: 200)]
        welcomeLabel.heroModifiers = fadeInUpModifiers
        cardView.heroModifiers = fadeInUpModifiers
        hero_unwindToRootViewController()
    }

    
    // MARK: - TextFieldDelegate Functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == usernameTextField && self.usernameError.alpha == 1 {
            hideError(.username)
        } else if textField == emailTextField && self.emailTextField.alpha == 1 {
            hideError(.email)
        } else if textField == passwordTextField && self.passwordTextField.alpha == 1 {
            hideError(.password)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text == "" else { return }
        if textField == emailTextField {
            self.view.removeConstraint(emailPlaceholderConstraint)
            self.view.addConstraint(emailPlaceholderActiveConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if textField == usernameTextField {
            self.view.removeConstraint(usernamePlaceholderConstraint)
            self.view.addConstraint(usernamePlaceholderActiveConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.removeConstraint(passwordPlaceholderConstraint)
            self.view.addConstraint(passwordPlaceholderActiveConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text == "" else { return }
        if textField == emailTextField {
            self.view.removeConstraint(emailPlaceholderActiveConstraint)
            self.view.addConstraint(emailPlaceholderConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if textField == usernameTextField {
            self.view.removeConstraint(usernamePlaceholderActiveConstraint)
            self.view.addConstraint(usernamePlaceholderConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.removeConstraint(passwordPlaceholderActiveConstraint)
            self.view.addConstraint(passwordPlaceholderConstraint)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard show size: \(keyboardSize)")
            self.view.addGestureRecognizer(tapGestureRecognizer)
            self.view.removeConstraints([centerYConstraint, centerXConstraint])
            self.view.addConstraint(cardViewTopConstraint)
            UIView.animate(withDuration: 0.3) {
                self.welcomeLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard hide size: \(keyboardSize)")
            self.view.removeGestureRecognizer(tapGestureRecognizer)
            self.view.removeConstraint(cardViewTopConstraint)
            self.view.addConstraints([centerYConstraint, centerXConstraint])
            UIView.animate(withDuration: 0.3) {
                self.welcomeLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        if isWaitingForKeyboardDismissal {
            hero_dismissViewController()
            isWaitingForKeyboardDismissal = false
        }
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}

enum ValidationError {
    case username
    case email
    case password
}
