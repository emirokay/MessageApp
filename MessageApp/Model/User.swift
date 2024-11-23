//
//  User.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String?
    let fullname: String
    let email: String
    var bio: String?
    var profileImageUrl: URL?
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
}

extension User {
	static let Unkonw = User(uid: "0", fullname: "Unknown", email: "Unknown")
    static let MOCK_USER = User(uid: "1", fullname: "Bruce Wayne", email: "batman@mail.com", bio: "I am not batman for gods sake who is telling you this joker?? wtf guys??")
    static let MOCK_USER2 = User(uid: "2", fullname: "Harley quenn", email: "harley@mail.com", bio: "joker my love <3")
    static let MOCK_USER3 = User(uid: "3", fullname: "Clarck kent", email: "clark@mail.com", bio: "anyone know cheap glasses store? ")
}
