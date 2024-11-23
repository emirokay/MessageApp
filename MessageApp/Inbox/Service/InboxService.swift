//
//  InboxService.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class InboxService {
    @Published var documentChanges = [DocumentChange]()
    
    func observeRecentChats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let query = Firestore.firestore().collection("chats").whereField("participants", arrayContains: uid).order(by: "updatedAt", descending: false)
        
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added || $0.type == .modified}) else { return }
            self.documentChanges = changes
        }
    }
    
    func createChat(groupName: String, groupProfileImage: Data?, userIds: [String], chatType: String, createdBy: String, admins: [String]) -> String {
        NetworkManager.shared.isLoading = true
        
        let db = Firestore.firestore()
        let newChatRef = db.collection("chats").document()
        
        let chatData: [String: Any] = [
            "chatId": newChatRef.documentID,
            "chatName": groupName,
			"chatBio": "",
            "chatProfileUrl": "",
            "participants": userIds,
            "type": chatType,
            "createdAt": Date(),
			"createdBy": createdBy,
			"admins": admins,
            "updatedAt": Date(),
            "lastMessage": ""
        ]
        
        newChatRef.setData(chatData) { error in
            if let error = error {
                NetworkManager.shared.setError(error)
                print("Error creating chat: \(error.localizedDescription)")
            } else {
                print("Chat created successfully")
                if groupProfileImage != nil {
                    if let groupProfileImage = groupProfileImage {
                        let storageRef = Storage.storage().reference().child("ProfileImages").child(newChatRef.documentID)
                        
                        storageRef.putData(groupProfileImage, metadata: nil) { metadata, error in
                            if let error = error {
                                NetworkManager.shared.setError(error)
                                print("Error uploading message image: \(error.localizedDescription)")
                            } else {
                                storageRef.downloadURL { url, error in
                                    if let downloadURL = url {
                                        newChatRef.updateData(["chatProfileUrl": downloadURL.absoluteString])
                                        print("Message sent successfully with download URL")
                                    } else {
                                        let customError = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error retrieving download URL"])
                                        NetworkManager.shared.setError(customError)
                                        print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown")")
                                    }
                                }
                            }
                        }
                    } else {
                        print("Message sent successfully without image")
                    }
                }
                newChatRef.updateData(["updatedAt": Date()])
            }
        }
  
        NetworkManager.shared.isLoading = false
        return newChatRef.documentID
    }
    
}

