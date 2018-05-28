//
//  SignInVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/9/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Hero
import Stevia
import Firebase

class SignInVC: UIViewController, UITextFieldDelegate {

    // MARK: - Views
    let backgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "backgroundImage")
        return imageView
    }()
    
    lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back!"
        label.font = UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(28))
        label.textColor = .white
        return label
    }()
    
    let welcomeMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
        shadowView.heroID = "cardView"
        return shadowView
    }()
    
    lazy var emailPlaceholder: UILabel = {
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
        textField.tag = 0
        textField.autocapitalizationType = .none
        textField.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(18))
        textField.textColor = UIColor(hexString: "3C3C3C")
        return textField
    }()
    
    lazy var passwordPlaceholder: UILabel = {
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
    
    // MARK: - Buttons
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "backArrow"), for: .normal)
        button.heroID = "backButton"
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedString = NSMutableAttributedString(string: "SIGN IN" as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor.white])
        button.setAttributedTitle(attributedString, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = button.frame.width / 2
        button.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedString = NSMutableAttributedString(string: "Forgot password?" as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(14))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor(hexString: "#FF6322")])
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return button
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        let buttonTitleString = NSString(string: "Don't have an account?  Sign Up")
        let range = buttonTitleString.range(of: "Sign Up")
        let attributedString = NSMutableAttributedString(string: buttonTitleString as String,
                                                         attributes: [NSAttributedStringKey.font : UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))!,
                                                                      NSAttributedStringKey.foregroundColor : UIColor.white.withAlphaComponent(0.8)])
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont(name: "ProximaNova-SemiBold", size: adaptConstant(16))!,
                                        NSAttributedStringKey.foregroundColor : UIColor.white], range: range)
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Variables
    var isWaitingForKeyboardDismissal = false
    var isTransitioningToSignUpVC = false
    var isFromSignUpVC = false
    
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
        
        signInButton.applyGradient(colors: [UIColor(hexString: "#FF8C2B").cgColor, UIColor(hexString: "#FF6322").cgColor])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUpViews() {
        self.view.sv(
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
                forgotPasswordButton,
                signInButton
            ),
            signUpButton
        )
        
        applyConstraints()
        applyHeroModifiers()
    }
    
    func applyConstraints() {
        backButton.top(adaptConstant(45))
        backButton.left(adaptConstant(10))
        backgroundView.fillContainer()
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
        
        signInButton.height(adaptConstant(45))
        signInButton.Width == signInButton.Height * 2.8
        signInButton.right(adaptConstant(18)).bottom(adaptConstant(22))
        signInButton.Top == passwordTextFieldBottomBorder.Bottom + adaptConstant(45)
        
        forgotPasswordButton.left(adaptConstant(18))
        forgotPasswordButton.CenterY == signInButton.CenterY
        
        signUpButton.Top == cardView.Bottom + adaptConstant(18)
        signUpButton.centerHorizontally()
    }
    
    func applyHeroModifiers() {
        if isTransitioningToSignUpVC {
            let modifiers: [HeroModifier] = [.duration(0.3), .forceNonFade, .translate(x: -self.view.frame.width)]
            welcomeLabel.heroModifiers = [.fade, .translate(y: -adaptConstant(45))]
            signUpButton.heroModifiers = [.fade, .translate(y: -adaptConstant(45))]
            cardView.heroModifiers = modifiers
        } else if isFromSignUpVC {
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
    
    @objc func backButtonTapped() {
        let fadeInUpModifiers: [HeroModifier] = [.fade, .translate(y: adaptConstant(180))]
        welcomeLabel.heroModifiers = fadeInUpModifiers
        cardView.heroModifiers = fadeInUpModifiers
        if emailTextField.isEditing {
            isWaitingForKeyboardDismissal = true
            view.endEditing(true)
        } else {
            hero_unwindToRootViewController()
        }
    }
    
    @objc func signUpButtonTapped() {
        let signUpVC = SignUpVC()
        signUpVC.isHeroEnabled = true
        self.isTransitioningToSignUpVC = true
        signUpVC.isFromSignInVC = true
        applyHeroModifiers()
        self.present(signUpVC, animated: true, completion: nil)
    }
    
    @objc func signInButtonTapped() {
        guard let emailText = emailTextField.text else {
            print("Email field is empty.")
            return
        }
        
        guard let passwordText = passwordTextField.text else {
            print("Password field is empty.")
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
                // login
                Auth.auth().signIn(withEmail: email, password: passwordText, completion: { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        let ac = UIAlertController(title: "Incorrect Password", message: "Please enter the correct password and try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                        return
                    }
                    
                    if let user = user {
                        print("Signed in as user: \(user)")
                        self.view.endEditing(true)
                        let mainTabBarController = MainTabBarController()
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                        
                        appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                        
                        UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                            appDelegate.window?.rootViewController = mainTabBarController
                        }, completion: nil)
                    }
                })
            } else {
                let ac = UIAlertController(title: "Error", message: "No accounts are registered with that email address.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    @objc func forgotPassword() {
        let ac = UIAlertController(title: "Forgot password?", message: "Enter your email address below to receive a link to reset your password.", preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter email address"
            textField.keyboardType = .emailAddress
        }
        ac.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: { (_) in
            let resetEmail = ac.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        let resetFailedAlert = UIAlertController(title: "Reset failed", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
                        resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetFailedAlert, animated: true, completion: nil)
                    } else {
                        let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                        resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(resetEmailSentAlert, animated: true, completion: nil)
                    }
                }
            })
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
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
            hero_unwindToRootViewController()
            isWaitingForKeyboardDismissal = false
        }
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}
