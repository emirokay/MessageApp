//
//  ChatService.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ChatService {
    
    var chatId: String
    
    func sendMessage(messageContent: String, messageImageData: Data?) {
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let chatRef = db.collection("chats").document(chatId)
        let newMessageRef = chatRef.collection("messages").document()
        let downloadURL = messageImageData != nil ? "updating" : ""
        let lastMessage = messageContent == "" && messageImageData != nil ? "photo" : messageContent
        
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "content": messageContent,
            "timestamp": Date(),
            "downloadURL": downloadURL
        ]
        
        newMessageRef.setData(messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message data set successfully")
                    if let messageImageData = messageImageData {
                        let storageRef = Storage.storage().reference().child("MessageImages").child(chatId).child(newMessageRef.documentID)
                        
                        storageRef.putData(messageImageData, metadata: nil) { metadata, error in
                            if let error = error {
                                print("Error uploading message image: \(error.localizedDescription)")
                            } else {
                                storageRef.downloadURL { url, error in
                                    if let downloadURL = url {
                                        newMessageRef.updateData(["downloadURL": downloadURL.absoluteString])
                                        print("Message sent successfully with download URL")
                                    } else {
                                        print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown")")
                                    }
                                }
                            }
                        }
                    } else {

                        print("Message sent successfully without image")
                    }
                    chatRef.updateData(["lastMessage": lastMessage])
                    chatRef.updateData(["updatedAt": Date()])
                }
            }
        
    }

    func observeMessages(completion: @escaping ([Message]) -> Void) {
        let messagesRef = Firestore.firestore().collection("chats").document(chatId).collection("messages")
        let query = messagesRef.order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let snapshot = snapshot else {
                print("DEBUG: No snapshot data")
                completion([])
                return
            }
            
            let updatedMessages = snapshot.documentChanges.compactMap { change -> Message? in
                        switch change.type {
                        case .added, .modified:
                            do {
                                let message = try change.document.data(as: Message.self)
                                return message
                            } catch {
                                print("Error parsing message data: \(error.localizedDescription)")
                                return nil
                            }
                        default:
                            return nil
                        }
                    }
            
            completion(updatedMessages)
        }
    }
    
}
