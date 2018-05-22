//
//  MessagesVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/2/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MessagesVC: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String:[String:Message]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.navigationItem.title = "Messages"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: "messageCell")
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.height(1)
        self.tableView.tableFooterView = footerView
        observeMessages()
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = FirebaseController.shared.ref.child("userMessages").child(uid)
        
        ref.observe(.childAdded) { (snapshot) in
            SVProgressHUD.show()
            let userID = snapshot.key
            FirebaseController.shared.ref.child("userMessages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                self.fetchMessage(withID: messageID)
            })
        }
        
        ref.observe(.childRemoved) { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReload()
        }
    }
    
    func fetchMessage(withID messageID: String) {
        let messagesRef = FirebaseController.shared.ref.child("messages").child(messageID)
        
        messagesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerID = message.chatPartnerID() {
                    //self.messagesDictionary[chatPartnerID]![message.recipeID] = message
                    if self.messagesDictionary[chatPartnerID] == nil {
                        self.messagesDictionary[chatPartnerID] = [message.recipeID: message]
                    } else {
                        self.messagesDictionary[chatPartnerID]!.updateValue(message, forKey: message.recipeID)
                    }
                }
                
                self.attemptReload()
            }
        }
    }
    
    var timer: Timer?
    
    func attemptReload() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        // one message for each recipeID.
        self.messages.removeAll()
        self.messagesDictionary.forEach { (key, value) in
            // chatPartnerID: [recipeID: Message, recipeID: Message, recipeID: Message]
            let recipeIDMessagePairs: [String:Message] = value
            self.messages.append(contentsOf: recipeIDMessagePairs.values)
        }
        
        self.messages.sort { (m1, m2) -> Bool in
            return m1.timestamp.compare(m2.timestamp) == .orderedDescending
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerID = message.chatPartnerID() else { return }
        SVProgressHUD.show()
        FirebaseController.shared.fetchUserWithUID(uid: chatPartnerID) { (user) in
            guard let user = user else { return }
            FirebaseController.shared.fetchRecipeWithUID(uid: message.recipeID, completion: { (recipe) in
                guard let recipe = recipe else { return }
                let chat = Chat(recipe: recipe, withUser: user)
                self.showChatControllerForChat(chat)
            })
        }
        
    }
    
    func showChatControllerForChat(_ chat: Chat) {
        let chatLogVC = ChatLogVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.chat = chat
        chatLogVC.isFromRecipeDetailView = false
        navigationController?.pushViewController(chatLogVC, animated: true)
        SVProgressHUD.dismiss()
    }
}

