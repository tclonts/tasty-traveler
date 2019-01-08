//
//  AppMessagingChatLogVC.swift
//  TastyTraveler
//
//  Created by Kevin Wood on 12/12/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AppMessagingChatLogVC: UITableViewController, TextInputAccessoryViewDelegate {
    
    var messages: [Message] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var users: [String] = [] {
        didSet {
            print(users)
        }
    }
    func didSend(for message: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        for user in users {
            let ref = FirebaseController.shared.ref.child("messages")
            let childRef = ref.childByAutoId()
            let toID = user
            let fromID = uid
            let timestamp = Date().timeIntervalSince1970
            
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
        textInputAccessoryView.inputTextView.text = nil
    }
    
    func fetchUsers() {
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                var fetchedUsers: [String] = []
                for user in dictionary.keys {
//                    if user != "Zzk10HjWRWOXlBnCmbK2STYBj2N2" {
//                        fetchedUsers.append(user)
//                    }
                    
                    if user == "k83iGrQWpEQLCYcJY0UWZpoy6aw1" || user == "yILWP17repPgr6tLDKzBSFyc8jr1" {
                        fetchedUsers.append(user)
                    }
                }
                fetchedUsers.append("appMessages")
                self.users = fetchedUsers
                print(self.users)
            }
        }
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("userMessages/\(uid)/appMessages/").observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                var fetchedMessages: [Message] = []
                dictionary.forEach({ (_, value) in
                    
                    guard let messageIDDictionary = value as? [String:Any] else { return }
                    
                    let messageID = messageIDDictionary.keys.first!
                    
                    Database.database().reference().child("messages/\(messageID)").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let messageDictionary = snapshot.value as? [String:Any] {
                            let message = Message(uid: "", dictionary: messageDictionary)
                            fetchedMessages.append(message)
                            
                        }
                        self.messages = fetchedMessages.sorted(by: {$0.timestamp < $1.timestamp})
                    })
                })
            }
        }
    }
    
    func setUpNavigationTitle() {
        navigationItem.title = "In App Messaging System"
    }
    
    lazy var textInputAccessoryView: TextInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: adaptConstant(50))
        let textInputView = TextInputAccessoryView(frame: frame)
        textInputView.delegate = self
        return textInputView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeMessages()
        fetchUsers()
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
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        
        setUpCell(cell, message: message)
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(message.text).width + adaptConstant(24)
        
        return cell
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: self.view.frame.width * 0.7, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: ProximaNova.regular.of(size: 16)], context: nil)
    }
    
    func setUpCell(_ cell: ChatMessageCell, message: Message) {
        
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
