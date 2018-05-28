//
//  ChatLogVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase

class ChatLogVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, TextInputAccessoryViewDelegate {
    
    var chat: Chat? {
        didSet {
            setUpNavigationTitle()
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var isViewingChat = false
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toID = chat?.withUser.uid else { return }
        
        let userMessagesRef = FirebaseController.shared.ref.child("userMessages").child(uid).child(toID)
        userMessagesRef.observe(.childAdded) { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = FirebaseController.shared.ref.child("messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String:Any] else { return }
                var message = Message(uid: snapshot.key, dictionary: dictionary)
                
                if let isUnread = dictionary["unread"] as? Bool, isUnread, message.toID == uid, self.isViewingChat {
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
                
                if message.recipeID == self.chat!.recipe.uid {
                    
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        // scroll to the last index
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    var isFromRecipeDetailView = false
    
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
        recipeLabel.text = chat?.recipe.name
        
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
        
        if isFromRecipeDetailView {
            let closeButton = UIButton(type: .system)
            closeButton.setImage(#imageLiteral(resourceName: "closeButton"), for: .normal)
            closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: closeButton)
            self.navigationItem.leftBarButtonItem = barButton
        } else {
            let infoButton = UIButton(type: .infoLight)
            infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: infoButton)
            self.navigationItem.rightBarButtonItem = barButton
        }
        
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: adaptConstant(8), left: 0, bottom: adaptConstant(50), right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: adaptConstant(8), left: 0, bottom: adaptConstant(50), right: 0)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "chatMessageCell")
        
        collectionView?.keyboardDismissMode = .interactive
        
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
        recipeDetailVC.recipeHeaderView.photoImageView.loadImage(urlString: chat!.recipe.photoURL, placeholder: nil)
        recipeDetailVC.isFromChatLogVC = true
        recipeDetailVC.isFromFavorites = true
        
        let recipeNavigationController = UINavigationController(rootViewController: recipeDetailVC)
        recipeNavigationController.navigationBar.isHidden = true
        
//        self.navigationController?.pushViewController(recipeDetailVC, animated: true)
        self.present(recipeNavigationController, animated: true, completion: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func didSend(for message: String) {
        let ref = FirebaseController.shared.ref.child("messages")
        let childRef = ref.childByAutoId()
        let toID = chat!.withUser.uid
        let fromID = Auth.auth().currentUser!.uid
        let timestamp = Date().timeIntervalSince1970
        let recipeID = chat!.recipe.uid
        
        let values: [String:Any] = ["toID": toID,
                                    "fromID": fromID,
                                    "timestamp": timestamp,
                                    "recipeID": recipeID,
                                    "text": message,
                                    "unread": true]
        
        childRef.updateChildValues(values) { (error, ref) in
            if let error = error { print(error); return }
            
            self.textInputAccessoryView.clearMessageTextField()
            
            let userMessagesRef = FirebaseController.shared.ref.child("userMessages").child(fromID).child(toID)
            let messageID = childRef.key
            userMessagesRef.updateChildValues([messageID: true])
            
            let recipientUserMessagesRef = FirebaseController.shared.ref.child("userMessages").child(toID).child(fromID)
            recipientUserMessagesRef.updateChildValues([messageID: true])
            
            (self.inputAccessoryView as! TextInputAccessoryView).sendButton.isEnabled = true
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatMessageCell", for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        
        setUpCell(cell, message: message)
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(message.text).width + adaptConstant(32)
        cell.textView.isHidden = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        height = estimateFrameForText(message.text).height + adaptConstant(20)
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
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
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleView.layer.borderColor = UIColor.clear.cgColor
            cell.bubbleView.layer.borderWidth = 0
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            // incoming white with border
            cell.bubbleView.backgroundColor = .white
            cell.textView.textColor = Color.darkText
            cell.bubbleView.layer.borderColor = Color.lightGray.cgColor
            cell.bubbleView.layer.borderWidth = 1
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
}
