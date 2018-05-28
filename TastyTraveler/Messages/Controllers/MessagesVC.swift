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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Color.blackText, NSAttributedStringKey.font: UIFont(name: "ProximaNova-Bold", size: adaptConstant(20))!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.tableView.register(MessageCell.self, forCellReuseIdentifier: "messageCell")
        let footerView = UIView()
        footerView.backgroundColor = .white
        footerView.height(1)
        self.tableView.tableFooterView = footerView
        
        updateTitle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMessages), name: Notification.Name("ReloadMessages"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTitle), name: Notification.Name("UpdateTitle"), object: nil)
    }
    
    @objc func updateTitle() {
        if FirebaseController.shared.unreadMessagesCount > 0 {
            self.navigationItem.title = "Messages (\(FirebaseController.shared.unreadMessagesCount))"
        } else {
            self.navigationItem.title = "Messages"
        }
    }
    
    @objc func reloadMessages() {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FirebaseController.shared.messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        
        let message = FirebaseController.shared.messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = FirebaseController.shared.messages[indexPath.row]
        
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

