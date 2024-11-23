//
//  Message.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var messageId: String?
    let senderId: String
    let content: String
    let timestamp: Timestamp
    var downloadURL: String?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var isFromCurrentUser: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }
    
    var timestampString: String {
        return timestamp.dateValue().timestampString()
    }
}

struct Chat: Identifiable, Codable, Hashable {
    var chatId: String?
    let chatName: String
	let chatBio: String
    let chatProfileUrl: String?
    let participants: [String]
    let type: String
    let createdAt: Date
	let createdBy: String
	let admins: [String]
    let updatedAt: Date
    var lastMessage: String?
    var messages: [Message]?
    var users: [User]?
        
    var id: String {
        return chatId ?? ""
    }
    
}
