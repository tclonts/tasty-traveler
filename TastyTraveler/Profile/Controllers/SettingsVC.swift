//
//  SettingsVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/17/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation
import Firebase
import StoreKit
import Stevia
import FacebookLogin
import SVProgressHUD

class SettingsVC: FormViewController {
    
    var bioToSet = ""
    let accountVC = AccountVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProviders()
        
        accountVC.bioToSet = bioToSet
        
        self.navigationItem.title = "Settings"
        self.view.backgroundColor = UIColor(hexString: "F8F8FB")
        self.tableView.backgroundColor = UIColor(hexString: "F8F8FB")
        
        let leftBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSettings))
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Color.blackText
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        form +++
            Section()
                <<< ButtonRow("Account") { row in
                        row.title = row.tag
                        row.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback(builder: { () -> AccountVC in
                            return self.accountVC
                        }), onDismiss: nil)
                    }
        +++ Section()
                <<< ButtonRow("Rate Tasty Traveler") { row in
                        row.title = row.tag
                    }.cellUpdate { cell, row in
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textAlignment = .left
                        cell.textLabel?.textColor = .black
                    }.onCellSelection { cell, row in
                        if #available(iOS 10.3, *) {
                            SKStoreReviewController.requestReview()
                        } else {
                            if let reviewURL = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1279816444?mt=8"), UIApplication.shared.canOpenURL(reviewURL) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(reviewURL)
                                }
                            }
                        }
                    }
                <<< ButtonRow("Privacy Policy") { row in
                        row.title = row.tag
                    }.cellUpdate { cell, row in
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textColor = .black
                        cell.textLabel?.textAlignment = .left
                    }
                <<< CheckRow("Changelog") { row in
                        row.title = row.tag
                    
                    }.cellUpdate { cell, row in
                        cell.accessoryType = .disclosureIndicator
                        cell.textLabel?.textColor = .black
                        cell.textLabel?.textAlignment = .left
                        let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
                        cell.detailTextLabel?.text = version
                        cell.detailTextLabel?.textColor = Color.gray
                    }
        +++ Section()
                <<< ButtonRow("Sign Out") { row in
                        row.title = row.tag
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textColor = .red
                        cell.textLabel?.textAlignment = .center
                    }.onCellSelection { cell, row in
                        self.handleSignOut()
                    }
        
    }
    
    func fetchProviders() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let accountRow = form.rowBy(tag: "Account") {
            accountRow.disabled = true
            accountRow.evaluateDisabled()
        }
        
        Auth.auth().fetchProviders(forEmail: currentUser.email!) { (providers, error) in
            if let providers = providers {
                if providers.count == 1 && providers.contains("facebook.com") {
                    // using facebook
                    // show username
                    self.accountVC.showEmail = false
                } else if providers.count == 2 {
                    // using facebook and email
                    // show username, email, password, and change password
                    self.accountVC.showEmail = true
                    self.accountVC.facebookLinked = true
                } else {
                    // using email
                    // show username, email, link facebook, password, and change password
                    self.accountVC.showEmail = true
                    self.accountVC.facebookLinked = false
                }
            }
            
            if let accountRow = self.form.rowBy(tag: "Account") {
                accountRow.disabled = false
                accountRow.evaluateDisabled()
            }
        }
    }
    
    @objc func closeSettings() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSignOut() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            do {
                try Auth.auth().signOut()
                
                appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
                UIView.transition(with: appDelegate.window!, duration: 0.5, options: .transitionFlipFromTop, animations: {
                    appDelegate.window?.rootViewController = AccountAccessVC()
                }, completion: nil)
            
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
}

class AccountVC: FormViewController, UITextFieldDelegate {
    
    var bio: String? {
        didSet {
            let bioRow = form.rowBy(tag: "Bio")
            bioRow?.baseValue = bio
            bioRow?.updateCell()
        }
    }
    
    lazy var rightBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAccountInfo))
    
    var username: String? {
        didSet {
            let usernameRow = form.rowBy(tag: "Username")
            usernameRow?.baseValue = username
            usernameRow?.updateCell()
        }
    }
    
    var email: String? {
        didSet {
            let emailRow = form.rowBy(tag: "Email")
            emailRow?.baseValue = email
            emailRow?.updateCell()
        }
    }
    
    var newUsername: String? {
        didSet {
            checkForNewValues()
        }
    }
    
    var newEmail: String? {
        didSet {
            checkForNewValues()
        }
    }
    
    var newBio: String? {
        didSet {
            checkForNewValues()
        }
    }
    
    var currentPassword: String?
    var bioToSet: String?
    var newPassword: String? {
        didSet {
            checkForNewValues()
        }
    }
    
    var changingPassword = false
    
    
    let usernameErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Username is required."
        label.textColor = .red
        label.font = ProximaNova.regular.of(size: 11)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Username is required."
        label.textColor = .red
        label.font = ProximaNova.regular.of(size: 11)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    let newPasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Username is required."
        label.textColor = .red
        label.font = ProximaNova.regular.of(size: 11)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Username is required."
        label.textColor = .red
        label.font = ProximaNova.regular.of(size: 11)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    let bioErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Exceeded maximum character limit. (80)"
        label.textColor = .red
        label.font = ProximaNova.regular.of(size: 11)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    var showEmail = false
    var facebookLinked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Account"
        self.view.backgroundColor = UIColor(hexString: "F8F8FB")
        self.tableView.backgroundColor = UIColor(hexString: "F8F8FB")
        
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAccountEdit))
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.hidesBackButton = true
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = Color.blackText
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        form +++ Section("Username")
                <<< TextRow("Username") {
                        $0.add(rule: RuleMaxLength(maxLength: 25))
                        $0.validationOptions = .validatesOnChange
                    }.cellSetup { cell, row in
                        cell.textField.placeholder = "Your username"
                        cell.textField.tag = 0
                        
                        cell.contentView.sv(self.usernameErrorLabel)
                        self.usernameErrorLabel.Bottom == cell.contentView.Top - 8
                        self.usernameErrorLabel.centerHorizontally()
                    }.cellUpdate { cell, row in
                        cell.textField.text = row.value
                        cell.textField.clearButtonMode = .always
                        
                        if !row.isValid {
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            self.usernameErrorLabel.text = "Username is too long."
                            UIView.animate(withDuration: 0.2, animations: {
                                self.usernameErrorLabel.alpha = 1
                            })
                        } else {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            UIView.animate(withDuration: 0.2, animations: {
                                self.usernameErrorLabel.alpha = 0
                            })
                        }
                    }.onChange { row in
                        if row.value != self.username! {
                            self.newUsername = row.value
                        }
                    }
            +++ Section("Bio")
                <<< TextAreaRow("Bio") {
                        $0.add(rule: RuleMaxLength(maxLength: 80))
                        $0.validationOptions = .validatesOnChange
                    }.cellSetup { cell, row in
                        cell.contentView.sv(self.bioErrorLabel)
                        self.bioErrorLabel.Bottom == cell.contentView.Top - 8
                        self.bioErrorLabel.centerHorizontally()
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            self.navigationItem.rightBarButtonItem?.isEnabled = false
                            UIView.animate(withDuration: 0.2, animations: {
                                self.bioErrorLabel.alpha = 1
                            })
                        } else {
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                            UIView.animate(withDuration: 0.2, animations: {
                                self.bioErrorLabel.alpha = 0
                            })
                        }
                    }.onChange { row in
                        if row.value != self.bio! {
                            self.newBio = row.value
                        }
                    }
        
        let currentUser = Auth.auth().currentUser!
        
        if let username = currentUser.displayName { self.username = username }
        if let bio = bioToSet { self.bio = bio }
        
        if showEmail {
            self.form
                +++ Section("Email")
                <<< TextRow("Email") {
                    $0.add(rule: RuleEmail())
                    $0.validationOptions = .validatesOnDemand
                    }.cellSetup { cell, row in
                        cell.textField.placeholder = "Your email address"
                        cell.textField.tag = 1
                        cell.textField.keyboardType = .emailAddress
                        
                        cell.contentView.sv(self.emailErrorLabel)
                        self.emailErrorLabel.Bottom == cell.contentView.Top - 8
                        self.emailErrorLabel.centerHorizontally()
                    }.cellUpdate { cell, row in
                        cell.textField.text = row.value
                        cell.textField.clearButtonMode = .always
                        
                        if !row.isValid {
                            //self.navigationItem.rightBarButtonItem?.isEnabled = false
                            self.emailErrorLabel.text = "Must be a valid email address."
                            UIView.animate(withDuration: 0.2, animations: {
                                self.emailErrorLabel.alpha = 1
                            })
                        } else {
                            //self.navigationItem.rightBarButtonItem?.isEnabled = true
                            UIView.animate(withDuration: 0.2, animations: {
                                self.emailErrorLabel.alpha = 0
                            })
                        }
                    }.onChange { row in
                        if row.value != self.email! {
                            self.newEmail = row.value
                        }
                }
                +++ Section()
                <<< ButtonRow("Link Facebook account") { row in
                        if self.facebookLinked {
                            row.title = "Facebook account linked"
                            row.disabled = true
                        } else {
                            row.title = "Link Facebook account"
                            row.disabled = false
                        }
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .center
                        
                    }.onCellSelection { cell, row in
                        self.facebookLogin()
                }
                +++ Section("Password")
                <<< TextRow("Password").cellSetup { cell, row in
                        cell.textField.placeholder = "Current password"
                        cell.textField.tag = 2
                        row.add(rule: RuleRequired())
                        cell.textField.isSecureTextEntry = true
                        row.validationOptions = .validatesOnDemand
                    
                        cell.contentView.sv(self.passwordErrorLabel)
                        self.passwordErrorLabel.Bottom == cell.contentView.Top - 8
                        self.passwordErrorLabel.centerHorizontally()
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            self.passwordErrorLabel.text = "Password is required."
                            UIView.animate(withDuration: 0.2, animations: {
                                self.passwordErrorLabel.alpha = 1
                            })
                        } else {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.passwordErrorLabel.alpha = 0
                            })
                        }
                    }.onChange { row in
                        self.currentPassword = row.value
                    }
                <<< TextRow("NewPassword") {
                        $0.hidden = true
                    }.cellSetup { cell, row in
                        cell.textField.placeholder = "New password"
                        cell.textField.tag = 3
                        cell.textField.isSecureTextEntry = true
                        
                        row.add(rule: RuleMinLength(minLength: 6))
                        row.validationOptions = .validatesOnDemand
                        
                        cell.contentView.sv(self.newPasswordErrorLabel)
                        self.newPasswordErrorLabel.Top == cell.contentView.Top
                        self.newPasswordErrorLabel.centerHorizontally()
                    }.cellUpdate { cell, row in
                        if !row.isValid {
                            self.newPasswordErrorLabel.text = "Must be at least 6 characters."
                            UIView.animate(withDuration: 0.2, animations: {
                                self.newPasswordErrorLabel.alpha = 1
                            })
                        } else {
                            UIView.animate(withDuration: 0.2, animations: {
                                self.newPasswordErrorLabel.alpha = 0
                            })
                        }
                    }.onChange { row in
                        self.newPassword = row.value
                    }
                <<< ButtonRow("Change password") { row in
                    row.title = row.tag
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .center
                    }.onCellSelection { cell, row in
                        self.changingPassword = !self.changingPassword
                        let newPasswordRow = self.form.rowBy(tag: "NewPassword")
                        
                        if self.changingPassword {
                            newPasswordRow?.hidden = false
                            newPasswordRow?.evaluateHidden()
                            row.title = "Cancel password change"
                            row.updateCell()
                        } else {
                            newPasswordRow?.hidden = true
                            newPasswordRow?.evaluateHidden()
                            row.title = "Change password"
                            row.updateCell()
                        }
                }
            if let email = currentUser.email { self.email = email }
        }
    }
    
    func checkForNewValues() {
        var newValues = false
        
        if newUsername != nil && newUsername != username { newValues = true }
        if newEmail != nil && newEmail != email { newValues = true }
        if newPassword != nil && currentPassword != nil { newValues = true }
        if newBio != nil && newBio != bio { newValues = true }
        
        if newValues {
            self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        } else {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    @objc func cancelAccountEdit() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAccountInfo() {
        guard let user = Auth.auth().currentUser else { return }
        
        if let bioRow = self.form.rowBy(tag: "Bio") {
            if let newBio = self.newBio {
                FirebaseController.shared.ref.child("users").child(user.uid).updateChildValues(["bio": newBio])
                
                self.bio = newBio
                self.newBio = nil
            }
        }
        
        if facebookLinked && !showEmail{
            self.saveNewUsername(completion: { (result) in
                if result {
                    SVProgressHUD.showSuccess(withStatus: "Saved")
                }
            })
            self.navigationController?.popViewController(animated: true)

            
        } else {
            guard let passwordRow = form.rowBy(tag: "Password") else { return }
            if !passwordRow.validate().isEmpty { return }
            
            guard let email = email, let currentPassword = currentPassword else { return }
            let emailCredential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            
            user.reauthenticate(with: emailCredential, completion: { (error) in
                if let error = error {
                    print(error)
                    self.passwordErrorLabel.text = "Password is invalid."
                    UIView.animate(withDuration: 0.2, animations: {
                        self.passwordErrorLabel.alpha = 1
                    })
                    return
                }
                
                self.saveNewUsername(completion: { (result) in
                    if !result { return }
                })
                
                if let emailRow = self.form.rowBy(tag: "Email") {
                    if !emailRow.validate().isEmpty { return }
                    
                    if let newEmail = self.newEmail {
                        user.updateEmail(to: newEmail, completion: { (error) in
                            if let error = error {
                                print(error)
                                return
                            }
                            self.email = newEmail
                            self.newEmail = nil
                        })
                        
                    }
                }
                
                if let newPasswordRow = self.form.rowBy(tag: "NewPassword") {
                    if !newPasswordRow.validate().isEmpty { return }
                    
                    if let newPassword = self.newPassword {
                        user.updatePassword(to: newPassword, completion: { (error) in
                            if let error = error {
                                print(error)
                                return
                            }
                            
                            self.currentPassword = newPassword
                            self.newPassword = nil
                        })
                    }
                }
                
                
                
                SVProgressHUD.showSuccess(withStatus: "Saved")
                SVProgressHUD.dismiss(withDelay: 2)
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func saveNewUsername(completion: @escaping(Bool) ->()) {
        guard let user = Auth.auth().currentUser else { completion(false); return }
        
        if let newUsername = newUsername {
            FirebaseController.shared.verifyUniqueUsername(newUsername, completion: { (result) in
                if result {
                    let usernameToRemove = self.username?.lowercased()
                    FirebaseController.shared.ref.child("usernames").child(usernameToRemove!).removeValue()
                    FirebaseController.shared.storeUsername(newUsername, uid: user.uid)
                    
                    self.username = newUsername
                    self.newUsername = nil
                    completion(true)
                } else {
                    self.usernameErrorLabel.text = "Username is already taken."
                    UIView.animate(withDuration: 0.2, animations: {
                        self.usernameErrorLabel.alpha = 1
                    })
                    completion(false)
                }
            })
        }
    }
    
    func facebookLogin() {
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
                
                guard let user = Auth.auth().currentUser else { return }
                
                user.link(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error)
                        if (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                            let ac = UIAlertController(title: "Already Linked", message: "This Facebook account is already linked with an account on Tasty Traveler.", preferredStyle: .alert)
                            
                            ac.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                            
                            self.present(ac, animated: true, completion: nil)
                        }
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    self.facebookLinked = true
                    let facebookRow = self.form.rowBy(tag: "Link Facebook account")
                    
                    if self.facebookLinked {
                        facebookRow?.title = "Facebook account linked"
                        facebookRow?.disabled = true
                    } else {
                        facebookRow?.title = "Link Facebook account"
                        facebookRow?.disabled = false
                    }
                    facebookRow?.updateCell()
                    
                    SVProgressHUD.dismiss()
                })
            }
        }
    }
}
