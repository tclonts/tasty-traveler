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
    
    let emptyLabel = UIStackView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white

        let emptyLabelTitle = UILabel()
        emptyLabelTitle.text = "You don't have any messages."
        emptyLabelTitle.textColor = Color.gray
        emptyLabelTitle.textAlignment = .center
        emptyLabelTitle.font = ProximaNova.semibold.of(size: 20)
        emptyLabelTitle.numberOfLines = 0
        
        let emptyLabelMessage = UILabel()
        emptyLabelMessage.text = "Any conversations you have with other cooks will show up here."
        emptyLabelMessage.textColor = Color.gray
        emptyLabelMessage.textAlignment = .center
        emptyLabelMessage.font = ProximaNova.regular.of(size: 16)
        emptyLabelMessage.numberOfLines = 0
        
        emptyLabel.addArrangedSubview(emptyLabelTitle)
        emptyLabel.addArrangedSubview(emptyLabelMessage)
        emptyLabel.axis = .vertical
        emptyLabel.spacing = adaptConstant(20)
        
        self.view.sv(emptyLabel)
        emptyLabel.centerInContainer().left(adaptConstant(20)).right(adaptConstant(20))
        emptyLabel.isHidden = FirebaseController.shared.messages.count != 0

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
        
        emptyLabel.isHidden = FirebaseController.shared.messages.count != 0
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
        
        updateTitle()
        
        guard let chatPartnerID = message.chatPartnerID() else { return }
        SVProgressHUD.show()
        FirebaseController.shared.fetchUserWithUID(uid: chatPartnerID) { (user) in
            guard let user = user else { return }
            if let recipeID = message.recipeID {
                FirebaseController.shared.fetchRecipeWithUID(uid: recipeID, completion: { (recipe) in
                    guard let recipe = recipe else { return }
                    let chat = Chat(recipe: recipe, withUser: user)
                    self.showChatControllerForChat(chat)
                })
            } else {
                let chat = Chat(recipe: nil, withUser: user)
                self.showChatControllerForChat(chat)
            }
        }
    }
    
    func showChatControllerForChat(_ chat: Chat) {
        let chatLogVC = ChatLogVC()
        chatLogVC.chat = chat
        chatLogVC.isFromRecipeDetailView = false
        navigationController?.pushViewController(chatLogVC, animated: true)
        SVProgressHUD.dismiss()
    }
}

