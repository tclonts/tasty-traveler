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
        textField.tag = 0
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
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
        textField.tag = 1
        textField.returnKeyType = .done
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
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
    lazy var emailPlaceholderConstraint = constraint(item: emailPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: emailTextField, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var emailPlaceholderActiveConstraint = constraint(item: emailPlaceholder, attribute: .bottom, relatedBy: .equal, toItem: emailTextField, attribute: .top, multiplier: 1, constant: -adaptConstant(7))
    lazy var passwordPlaceholderConstraint = constraint(item: passwordPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: passwordTextField, attribute: .centerY, multiplier: 1, constant: 0)
    lazy var passwordPlaceholderActiveConstraint = constraint(item: passwordPlaceholder, attribute: .bottom, relatedBy: .equal, toItem: passwordTextField, attribute: .top, multiplier: 1, constant: -adaptConstant(7))
    
    var isFromSignInVC = false
    var isWaitingForKeyboardDismissal = false
    var isTransitioningToSignInVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
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
        view.sv(
            backgroundView,
            welcomeMessageView.sv(welcomeLabel),
            backButton,
            cardView.sv(
                emailPlaceholder,
                emailTextField,
                emailTextFieldBottomBorder,
                passwordPlaceholder,
                passwordTextField,
                passwordTextFieldBottomBorder,
                signUpButton
            ),
            signInButton
        )
        
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
        welcomeLabel.centerInContainer()
        
        emailTextField.left(adaptConstant(18)).right(adaptConstant(18)).top(adaptConstant(45))
        equal(widths: [emailTextField, emailTextFieldBottomBorder])
        emailTextFieldBottomBorder.Top == emailTextField.Bottom + adaptConstant(7)
        emailTextFieldBottomBorder.centerHorizontally()
        
        emailPlaceholder.Left == emailTextField.Left
        
        passwordTextField.left(adaptConstant(18)).right(adaptConstant(18))
        passwordTextField.Top == emailTextFieldBottomBorder.Bottom + adaptConstant(45)
        equal(widths: [passwordTextField, passwordTextFieldBottomBorder])
        passwordTextFieldBottomBorder.Top == passwordTextField.Bottom + adaptConstant(7)
        passwordTextFieldBottomBorder.centerHorizontally()
        
        passwordPlaceholder.Left == passwordTextField.Left
        self.view.addConstraints([emailPlaceholderConstraint, passwordPlaceholderConstraint])
        
        signUpButton.height(adaptConstant(45))
        signUpButton.left(adaptConstant(18)).right(adaptConstant(18)).bottom(adaptConstant(22))
        signUpButton.Top == passwordTextFieldBottomBorder.Bottom + adaptConstant(45)
        
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
        let signInVC = SignInVC()
        signInVC.isHeroEnabled = true
        self.isTransitioningToSignInVC = true
        signInVC.isFromSignUpVC = true
        applyHeroModifiers()
        self.present(signInVC, animated: true, completion: nil)
    }
    
    @objc func signUpButtonTapped() {
        // validate email
        guard let emailText = emailTextField.text else {
            print("Email field is empty.")
            return
        }
        
        let validator = Validator()
        guard let email = validator.validate(email: emailText) else {
            print("Email is invalid.")
            return
        }
        
        Auth.auth().fetchProviders(forEmail: email) { (providers, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if providers != nil {
                let ac = UIAlertController(title: "Error", message: "An account already exists with that email address.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            } else {
                guard let password = self.passwordTextField.text else {
                    print("Password field is empty.")
                    return
                }
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    guard let uid = user?.uid else { return }
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        // FirebaseController.shared.storeUsername(username, uid: uid)
                        let mainTabBarController = MainTabBarController()
                        mainTabBarController.newUser = true
                        self.hero_replaceViewController(with: mainTabBarController)
                    }
                })
            }
        }
    }
    
    @objc func backButtonTapped() {
        let fadeInUpModifiers: [HeroModifier] = [.fade, .translate(y: 200)]
        welcomeLabel.heroModifiers = fadeInUpModifiers
        cardView.heroModifiers = fadeInUpModifiers
        hero_unwindToRootViewController()
    }

    
    // MARK: - TextFieldDelegate Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text == "" else { return }
        if textField == emailTextField {
            self.view.removeConstraint(emailPlaceholderConstraint)
            self.view.addConstraint(emailPlaceholderActiveConstraint)
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
