//
//  ChatLogVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatLogVC: UITableViewController, TextInputAccessoryViewDelegate {
    
    var chat: Chat? {
        didSet {
            setUpNavigationTitle()
            
            observeMessages()
        }
    }
    
    var messages: [Message] = [] {
        didSet {
            if self.messages.count > 0 {
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                    let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
                    let indexPath = IndexPath(row: lastRow, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    
                }
            }
        }
    }
    
    var isViewingChat = false
    
    func observeMessages() {
        self.textInputAccessoryView.inputTextView.becomeFirstResponder()
        
        guard let uid = Auth.auth().currentUser?.uid, let toID = chat?.withUser.uid else { return }
        
        var fetchedMessages: [Message] = []
        FirebaseController.shared.ref.child("userMessages/\(uid)/\(toID)").observe(.childAdded) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any] {
                dictionary.forEach({ (key, value) in
                    let messageID = key
                    let messagesRef = FirebaseController.shared.ref.child("messages").child(messageID)
                    messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let dictionary = snapshot.value as? [String:Any] else { return }
                        var message = Message(uid: snapshot.key, dictionary: dictionary)
                        
                        if message.isUnread, message.toID == uid, self.isViewingChat, message.recipeID == self.chat!.recipe?.uid {
                            message.isUnread = false
                            
                            FirebaseController.shared.ref.child("messages").child(messageID).child("unread").setValue(false)
                            
                            let unreadMessagesCountRef = FirebaseController.shared.ref.child("users").child(uid).child("unreadMessagesCount")
                            unreadMessagesCountRef.runTransactionBlock({ (currentCount) -> TransactionResult in
                                if var count = currentCount.value as? Int, count != 0 {
                                    count -= 1
                                    
                                    currentCount.value = count
                                    
                                    return TransactionResult.success(withValue: currentCount)
                                } else {
                                    return TransactionResult.success(withValue: currentCount)
                                }
                            }, andCompletionBlock: { (error, committed, snapshot) in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            })
                        }
                        
                        if message.recipeID == self.chat!.recipe?.uid {
                            
                            fetchedMessages.append(message)
                            
                        }
                        
                        self.messages = fetchedMessages.sorted(by: {$0.timestamp < $1.timestamp})
                    })
                })
            }
        }
    }
    
    var isFromRecipeDetailView = false
    
    @objc func keyboardWillShow(notification:NSNotification ) {
        if let newFrame = (notification.userInfo?[ UIKeyboardFrameEndUserInfoKey ] as? NSValue)?.cgRectValue {
            print(self.view.frame.height)
            let offset = self.view.frame.height * 0.0659
            let insets = UIEdgeInsetsMake( 0, 0, newFrame.height - offset, 0 )
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        let insets = UIEdgeInsetsMake( 0, self.view.frame.height * 0.0219, 0, 0 )
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    func setUpNavigationTitle() {
        let usernameLabel = UILabel()
        usernameLabel.font = ProximaNova.semibold.of(size: 18)
        usernameLabel.textColor = Color.blackText
        usernameLabel.textAlignment = .center
        usernameLabel.text = chat?.withUser.username
        
        let recipeLabel = UILabel()
        recipeLabel.font = ProximaNova.regular.of(size: 12)
        recipeLabel.textColor = Color.gray
        recipeLabel.textAlignment = .center
        
        if let recipeName = chat?.recipe?.name {
            recipeLabel.text = recipeName
        } else {
            recipeLabel.isHidden = true
        }
        
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, recipeLabel])
        stackView.axis = .vertical
        
        navigationItem.titleView = stackView
    }
    
    lazy var textInputAccessoryView: TextInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: adaptConstant(50))
        let textInputView = TextInputAccessoryView(frame: frame)
        textInputView.delegate = self
        return textInputView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textInputAccessoryView.inputTextView.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        if isFromRecipeDetailView {
            let closeButton = UIButton(type: .system)
            closeButton.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: closeButton)
            self.navigationItem.leftBarButtonItem = barButton
        } else if chat?.recipe == nil {
            print("NO RECIPE")
        } else {
            let infoButton = UIButton(type: .infoLight)
            infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: infoButton)
            self.navigationItem.rightBarButtonItem = barButton
        }
        
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 60
        tableView?.contentInsetAdjustmentBehavior = .never
        tableView?.backgroundColor = .white
        tableView?.alwaysBounceVertical = true
        tableView?.contentInset = UIEdgeInsets(top: adaptConstant(8), left: 0, bottom: adaptConstant(8), right: 0)
        tableView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView?.register(ChatMessageCell.self, forCellReuseIdentifier: "chatMessageCell")
        tableView?.keyboardDismissMode = .interactive
        
        navigationController?.navigationBar.tintColor = Color.blackText
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromRecipeDetailView {
            tabBarController?.tabBar.isHidden = true
        }
        isViewingChat = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isFromRecipeDetailView {
            tabBarController?.tabBar.isHidden = false
        }
        
        isViewingChat = false
    }
    
    @objc func closeButtonTapped() {
        self.inputAccessoryView?.isHidden = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func infoButtonTapped() {
        print("TO RECIPE VIEW!")
        
        let recipeDetailVC = RecipeDetailVC()
        recipeDetailVC.recipe = chat!.recipe
        //recipeDetailVC.formatCookButton()
        if let photoURL = chat?.recipe?.photoURL {
            recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: photoURL, placeholder: nil)
        }
        recipeDetailVC.isFromChatLogVC = true
        recipeDetailVC.isFromFavorites = true
        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
        recipeNavigationController.navigationBar.isHidden = true
        
        self.navigationController?.pushViewController(recipeDetailVC, animated: true)
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func didSend(for message: String) {
        let ref = FirebaseController.shared.ref.child("messages")
        let childRef = ref.childByAutoId()
        let toID = chat!.withUser.uid
        let fromID = Auth.auth().currentUser!.uid
        let timestamp = Date().timeIntervalSince1970
        let recipeID = chat!.recipe?.uid
        
        if recipeID != nil && recipeID != "" {
            let values: [String:Any] = ["toID": toID,
                                        "fromID": fromID,
                                        "timestamp": timestamp,
                                        "recipeID": recipeID!,
                                        "text": message,
                                        "unread": true]
            
            childRef.setValue(values) { (error, ref) in
                if let error = error { print(error); return }
                
                self.textInputAccessoryView.clearMessageTextField()
                
                let messageID = childRef.key
                
                FirebaseController.shared.ref.child("userMessages/\(fromID)/\(toID)").childByAutoId().setValue([messageID: true])
                FirebaseController.shared.ref.child("userMessages/\(toID)/\(fromID)").childByAutoId().setValue([messageID: true])
                
                (self.inputAccessoryView as! TextInputAccessoryView).sendButton.isEnabled = true
            }
        } else {
            let values: [String:Any] = ["toID": toID,
                                        "fromID": fromID,
                                        "timestamp": timestamp,
                                        "text": message,
                                        "unread": true]
            
            childRef.setValue(values) { (error, ref) in
                if let error = error { print(error); return }
                
                self.textInputAccessoryView.clearMessageTextField()
                
                let messageID = childRef.key
                
                FirebaseController.shared.ref.child("userMessages/\(fromID)/\(toID)").childByAutoId().setValue([messageID: true])
                FirebaseController.shared.ref.child("userMessages/\(toID)/\(fromID)").childByAutoId().setValue([messageID: true])
                
                (self.inputAccessoryView as! TextInputAccessoryView).sendButton.isEnabled = true
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return textInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessageCell", for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        cell.message = message
        cell.messageLabel.text = message.text
        cell.selectionStyle = .none
        
        setUpCell(cell, message: message)
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(message.text).width + adaptConstant(24)
        //cell.textView.isHidden = false
        
        return cell
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: self.view.frame.width * 0.7, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: ProximaNova.regular.of(size: 16)], context: nil)
    }
    
    func setUpCell(_ cell: ChatMessageCell, message: Message) {
        if let profileImageURL = self.chat?.withUser.avatarURL {
            cell.profileImageView.loadImage(urlString: profileImageURL, placeholder: #imageLiteral(resourceName: "avatar"))
        }
        
        if message.fromID == Auth.auth().currentUser?.uid {
            // outgoing orange
            cell.bubbleView.backgroundColor = Color.primaryOrange
            cell.messageLabel.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleView.layer.borderColor = UIColor.clear.cgColor
            cell.bubbleView.layer.borderWidth = 0
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            // incoming white with border
            cell.bubbleView.backgroundColor = .white
            cell.messageLabel.textColor = Color.darkText
            cell.bubbleView.layer.borderColor = Color.lightGray.cgColor
            cell.bubbleView.layer.borderWidth = 1
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
}
