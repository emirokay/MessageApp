//
//  InboxViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Combine
import Firebase

class InboxViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var recentChats = [Chat]()

    private var fetchedUserIDs = Set<String>()
    @Published var newChatId = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let service = InboxService()
    
    init() {
        setupSubscribers()
        service.observeRecentChats()
    }
	
	func observeRecentChats() {
		service.observeRecentChats()
	}
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
        
        service.$documentChanges.sink { [weak self] changes in
            self?.loadInitialMessages(fromChanges: changes)
        }.store(in: &cancellables)

    }
    
	func createChat(groupName: String?, groupProfileImage: Data?, userIds: [String], chatType: String, createdBy: String, admins: [String]) {
        if !recentChats.isEmpty {
            for i in 0 ..< recentChats.count {
                if Set(recentChats[i].participants) == Set(userIds) {
                    self.newChatId = recentChats[i].id
                    break
                }
            }
        }
        if (self.newChatId == "") {
            self.newChatId = service.createChat(groupName: groupName ?? "", groupProfileImage: groupProfileImage ?? nil, userIds: userIds, chatType: chatType, createdBy: createdBy, admins: admins)
        }
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        let dispatchGroup = DispatchGroup()
            var chats: [Chat] = []

            for documentChange in changes {
                let document = documentChange.document
                let data = document.data()

                guard let chatId = data["chatId"] as? String,
                      let chatName = data["chatName"] as? String,
					  let chatBio = data["chatBio"] as? String,
                      let chatProfileUrl = data["chatProfileUrl"] as? String,
                      let participants = data["participants"] as? [String],
                      let type = data["type"] as? String,
                      let createdAtTimestamp = data["createdAt"] as? Timestamp,
					  let createdBy = data["createdBy"] as? String,
					  let admins = data["admins"] as? [String],
                      let updatedAtTimestamp = data["updatedAt"] as? Timestamp,
                      let lastMessage = data["lastMessage"] as? String
                else {
                    print("Error parsing chat data")
                    continue
                }

                let createdAt = createdAtTimestamp.dateValue()
                let updatedAt = updatedAtTimestamp.dateValue()
                var users: [User] = []
				
                for participant in participants where participant != currentUser?.id {
					dispatchGroup.enter()
                    UserService.fetchUser(withUid: participant) { user in
                        users.append(user)
						dispatchGroup.leave()
                    }
                }
				
                dispatchGroup.notify(queue: .main) {
                    let chat = Chat(chatId: chatId,
                                    chatName: chatName,
									chatBio: chatBio,
                                    chatProfileUrl: chatProfileUrl,
                                    participants: participants,
                                    type: type,
                                    createdAt: createdAt,
									createdBy: createdBy,
									admins: admins,
                                    updatedAt: updatedAt,
                                    lastMessage: lastMessage,
                                    messages: nil,
                                    users: users)
                    chats.append(chat)
                    self.updateRecentChats(with: chats)
                }
            }
    }
    
    private func updateRecentChats(with newChats: [Chat]) {
        for i in 0 ..< newChats.count {
           let chat = newChats[i]
           
           if let row = self.recentChats.firstIndex(where: {$0.id == chat.id}) {
               self.recentChats.remove(at: row)
               self.recentChats.insert(newChats[i], at: 0)
           } else {
               self.recentChats.insert(newChats[i], at: 0)
           }
       }
    }
}
