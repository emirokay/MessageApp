//
//  ChatDetailsViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 4.03.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

@MainActor
class ChatDetailsViewModel: ObservableObject {
	@Published var searchText = ""
	@Published var groupName = ""
	
	@Published var groupBio = "Add group bio"
	@Published var placeHolderText = "Add group bio"
	
	@Published var chat: Chat?
	@Published var users = [User]()
	
	@Published var showChatAddView: Bool = false
	@Published var showEditChatView: Bool = false
	@Published var showAddChatBioView: Bool = false
	@Published var showMemberInfo: Bool = false
	@Published var showProfileDetails: Bool = false
	
	@Published var groupProfileImage: Image?
	@Published var groupProfileImageData: Data?
	@Published var selectedItem: PhotosPickerItem? {
		didSet { Task { try await loadImage() } }
	}
	
	var service = ChatDetailsService()
	var chatId: String
	init(chatId: String) {
		self.chatId = chatId
		Task {
			try await fetchChat(chatId: chatId)
			try await fetchUsers()
		}
	}
	
	var currUser: User {
		return UserService.shared.currentUser ?? User.Unkonw
	}
	
	var createdBy: String {
		if let chat {
			if chat.createdBy == currUser.id {
				return currUser.fullname
			} else {
				let user = chat.users?.first(where: { $0.id == chat.createdBy}) ?? User.Unkonw
				return user.fullname
			}
		}
		return ""
	}
	
	var searchableUsers: [User] {
		if searchText.isEmpty {
			return users
		} else {
			let lowercasedQuery = searchText.lowercased()
			return users.filter {
				$0.fullname.lowercased().contains(lowercasedQuery) || $0.email.lowercased().contains(lowercasedQuery)
			}
		}
	}
	
	func loadImage() async throws {
		guard let item =  selectedItem else { return }
		guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
		self.groupProfileImageData = imageData
		guard let uiImage = UIImage(data: imageData) else { return }
		self.groupProfileImage = Image(uiImage: uiImage)
	}
	
	func fetchChat(chatId: String) async throws {
		do {
			let dispatchGroup = DispatchGroup()
			var chat = try await service.fetchChat(chatId: chatId)
			
			var users: [User] = []

			for participant in chat.participants where participant != currUser.id {
				dispatchGroup.enter()
				UserService.fetchUser(withUid: participant) { user in
					users.append(user)
					dispatchGroup.leave()
				}
			}
			
			dispatchGroup.notify(queue: .main) {
				chat.users = users
				self.chat = chat
				self.groupName = chat.chatName
				if chat.chatBio != "" {
					self.groupBio = chat.chatBio
				}
				self.filterUsers(users: self.users)
			}
		} catch {
			NetworkManager.shared.setError(error)
		}
	}
	
	func fetchUsers() async throws {
		let users = try await UserService.fetchAllUsers()
		filterUsers(users: users)
	}
	
	func filterUsers(users: [User]) {
		let uid = Auth.auth().currentUser?.uid
		let filteredUsers = users.filter { user in
				guard let chatUsers = chat?.users else {
					return true 
				}
				return !chatUsers.contains { $0.id == user.id } && user.id != uid
			}
		self.users = filteredUsers
	}
	
	func addToGroup(chatId: String, selectedUsers: [User]) {
		let users = (chat?.users ?? []) + selectedUsers
		service.addToGroup(chatId: chatId, selectedUsers: users)
		Task {
			try await fetchChat(chatId: chatId)
		}
	}
	
	func saveGroupBio() {
		if let chat = chat {
			if groupBio != placeHolderText {
				service.saveGroupBio(chatId: chat.id, bio: groupBio)
				Task {
					try await fetchChat(chatId: chat.id)
				}
			}
		}
	}
	
	func saveGroupInfo() {
		guard let chat = chat else { return }

			service.saveGroupInfo(chatId: chat.id, groupName: groupName, profileImageData: groupProfileImageData) { [self] error in
				if let error = error {
					NetworkManager.shared.setError(error)
					print("Error saving group info: \(error.localizedDescription)")
				} else {
					Task {
						do {
							try await fetchChat(chatId: chat.id)
						} catch {
							NetworkManager.shared.setError(error)
							print("Error fetching updated chat data: \(error.localizedDescription)")
						}
					}
				}
			}

			groupProfileImageData = nil
			selectedItem = nil
	}
	
	func removeFromGroup(userId: String) {
		service.removeFromGroup(chatId: chatId, userId: userId)
		Task {
			try await fetchChat(chatId: chatId)
		}
	}
	
	func admin(userId: String) {
		if var chatAdmins = chat?.admins {
			if (chatAdmins.contains(userId)) {
				chatAdmins.removeAll(where: { $0 == userId})
				service.removeAdmin(chatId: chatId, admins: chatAdmins)
				Task {
					try await fetchChat(chatId: chatId)
				}
			} else {
				chatAdmins.append(userId)
				service.makeAdmin(chatId: chatId, admins: chatAdmins)
				Task {
					try await fetchChat(chatId: chatId)
				}
			}
		}
	}
	
	
}
