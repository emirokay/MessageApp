//
//  Constants.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase

struct FirestoreContents {
    static let UserCollection = Firestore.firestore().collection("users")
    static let MessagesCollection = Firestore.firestore().collection("messages")
    
    static let ChatMembersCollection = Firestore.firestore().collection("chats").document("chatId").collection("members")
    static let ChatMessagesCollection = Firestore.firestore().collection("chats").document("chatId").collection("messages")

    
}
