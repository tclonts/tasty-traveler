//
//  QuestionsVC.swift
//  TastyTraveler
//
//  Created by Michael Bart on 5/1/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Firebase

class QuestionsVC: UITableViewController {
    
    var received = [Question]()
    var asked = [Question]()
    var messages = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationItem.title = "Questions"
        
        self.tableView.register(QuestionCell.self, forCellReuseIdentifier: "questionCell")
        
        observeQuestions()
    }
    
    // question cell: fetch user, display profile image, display username, display recipe
    
    // questions > questionIDs >
    //                           recipeID
    //                           askerID
    //                           receiverID
    //
    //
    // chatLogs > questionIDs > messageIDs > fromID
    //                                       toID
    //                                       timestamp
    //                                       text
    //                                       unread
    //
    // userQuestions > questionIDs > true/false
    
    // case 1: Observe questions that I have received, observe
    //       observe: users/myUserID/userQuestions childAdded
    //             if childAdded: create question cell
    //             use childAdded id to fetch question info
    //                  if question.receiverID == myUserID: append to received array, else append to asked array
    //             use childAdded id to observe: questions/questionID/messages childAdded
    //                  append message info to question.messages array
    //       filter questions where receiverID == myUserID
    //
    
    // case 2: Fetching questions that I have asked
    
    // case 3: Recipe with questions has been deleted
    
    func observeQuestions() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userQuestionsRef = FirebaseController.shared.ref.child("users").child(userID).child("questions")
        userQuestionsRef.observe(.childAdded) { (snapshot) in
            let questionID = snapshot.key
            let questionRef = FirebaseController.shared.ref.child("questions").child(questionID)
            questionRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let questionDictionary = snapshot.value as? [String:String] else { return }
                
                var question = Question(uid: questionID, dictionary: questionDictionary) // snapshot.key  snapshot.value
                
                let uid = question.receiverID == userID ? question.askerID : question.receiverID
                
                FirebaseController.shared.fetchUserWithUID(uid: uid, completion: { (user) in
                    question.user = user
                    question.receiverID == userID ? self.received.append(question) : self.asked.append(question)
                    
                    self.attemptReload()
                })
                
                let chatLogRef = FirebaseController.shared.ref.child("chatLogs").child(snapshot.key)
                chatLogRef.observe(.childAdded, with: { (snapshot) in
                    chatLogRef.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let messageDictionary = snapshot.value as? [String:Any] else { return }
                        
                        var message = Message(uid: snapshot.key, dictionary: messageDictionary)
                        
                        if message.toID == userID { message.isUnread = true }

                        if question.receiverID == userID {
                            let index = self.received.index(where: { $0.uid == questionID })
                            self.received.remove(at: index!)
                            question.lastMessage = message
                            self.received.append(question)
                            
                            self.attemptReload()
                        } else {
                            let index = self.asked.index(where: { $0.uid == questionID })
                            self.asked.remove(at: index!)
                            question.lastMessage = message
                            self.asked.append(question)
                            
                            self.attemptReload()
                        }
                        
                    })
                })
            })
        }
    }
    
    var timer: Timer?
    
    func attemptReload() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleReload() {
        
        self.received.sort(by: { (q1, q2) -> Bool in
            return q1.lastMessage?.timestamp.compare(q2.lastMessage!.timestamp) == .orderedDescending
        })
        
        self.asked.sort(by: { (q1, q2) -> Bool in
            return q1.lastMessage?.timestamp.compare(q2.lastMessage!.timestamp) == .orderedDescending
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Received" : "Asked"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? received.count : asked.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! QuestionCell
        
        cell.question = indexPath.section == 0 ? received[indexPath.row] : asked[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
    }
}
