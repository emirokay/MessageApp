//
//  ChatDetailsService.swift
//  MessageApp
//
//  Created by Emir Okay on 4.03.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ChatDetailsService {
	
	func fetchChat(chatId: String) async throws -> Chat {
		guard let chat = try? await Firestore.firestore().collection("chats").document(chatId).getDocument(as: Chat.self) else {
			let customError = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error retrieving chat"])
			throw customError
		}
		return chat
	}
	
	static func fetchAllUsers() async throws -> [User] {
		let users: [User] = [User]()
		do {
			let snapshot = try await Firestore.firestore().collection("users").getDocuments()
			let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
			return users
		} catch {
			NetworkManager.shared.setError(error)
			print("DEBUG: Error fetching all users: \(error.localizedDescription)")
			return users
		}
	}
	
	func addToGroup(chatId: String, selectedUsers: [User]) {
		NetworkManager.shared.isLoading = true
		
		guard let uid = Auth.auth().currentUser?.uid else { return }
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		
		var userIds: [String] = [uid]
		for user in selectedUsers {
			userIds.append(user.id)
		}
		
		chatRef.setData(["participants": userIds], merge: true) { error in
				if let error = error {
					NetworkManager.shared.setError(error)
					print("Error updating document: \(error.localizedDescription)")
				} else {
					print("Document successfully updated")
				}
				NetworkManager.shared.isLoading = false
			}
	}
	
	func saveGroupBio(chatId: String, bio: String) {
		NetworkManager.shared.isLoading = true
		
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		
		chatRef.setData(["chatBio": bio], merge: true) { error in
				if let error = error {
					NetworkManager.shared.setError(error)
					print("Error updating document: \(error.localizedDescription)")
				} else {
					print("Document successfully updated")
				}
				NetworkManager.shared.isLoading = false
			}
	}
	
	func removeFromGroup(chatId: String, userId: String) {
		NetworkManager.shared.isLoading = true
		
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		
		chatRef.updateData(["participants": FieldValue.arrayRemove([userId])]) { error in
			if let error = error {
				NetworkManager.shared.setError(error)
				print("Error updating document: \(error.localizedDescription)")
			} else {
				print("Document successfully updated")
			}
			NetworkManager.shared.isLoading = false
		}
	}
	
	func makeAdmin(chatId: String, admins: [String]) {
		NetworkManager.shared.isLoading = true
		
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		chatRef.setData(["admins": admins], merge: true) { error in
			if let error = error {
				NetworkManager.shared.setError(error)
				print("Error updating document: \(error.localizedDescription)")
			} else {
				print("Document successfully updated")
			}
			NetworkManager.shared.isLoading = false
		}
	}
	
	func removeAdmin(chatId: String, admins: [String]) {
		NetworkManager.shared.isLoading = true
		
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		chatRef.setData(["admins": admins], merge: true) { error in
			if let error = error {
				NetworkManager.shared.setError(error)
				print("Error updating document: \(error.localizedDescription)")
			} else {
				print("Document successfully updated")
			}
			NetworkManager.shared.isLoading = false
		}
	}
	
	func saveGroupInfo(chatId: String, groupName: String, profileImageData: Data?, completion: @escaping (Error?) -> Void) {
		NetworkManager.shared.isLoading = true
		let db = Firestore.firestore()
		let chatRef = db.collection("chats").document(chatId)
		
		var updateData: [String: Any] = ["chatName": groupName]
		
		if profileImageData != nil {
			updateData["chatProfileUrl"] = "updating"
		}
		
		chatRef.setData(updateData, merge: true) { error in
			if let error = error {
				completion(error)
				return
			}
			
			if let profileImageData = profileImageData {
				let chatStorageRef = Storage.storage().reference().child("ProfileImages").child(chatId)
				chatStorageRef.putData(profileImageData, metadata: nil) { metadata, error in
					if let error = error {
						completion(error)
						return
					}
					
					chatStorageRef.downloadURL { url, error in
						if let error = error {
							completion(error)
							return
						}
						
						if let downloadURL = url {
							chatRef.updateData(["chatProfileUrl": downloadURL.absoluteString]) { error in
								NetworkManager.shared.isLoading = false
								completion(error)
							}
						} else {
							completion(NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error retrieving download URL"]))
						}
					}
				}
			} else {
				NetworkManager.shared.isLoading = false
				completion(nil)
			}
		}
	}

	
}

