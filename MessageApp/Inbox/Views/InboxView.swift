//
//  InboxView.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import SwiftUI

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
    @State private var showNewMessageView = false
    @State var showChat = false
	
    @State private var selectedUsers = [User]()
    @State private var groupName = ""
    @State private var groupProfileImage: Data?
    
    private var user: User? {
		return viewModel.currentUser
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.recentChats.isEmpty {
                    List {
                        ForEach(viewModel.recentChats) { chat in
                            ZStack {
                                NavigationLink(destination: ChatView(chat: chat)) {
                                    EmptyView()
                                }.opacity(0.0)
                                InboxRowView(chat: chat)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Text("No new messages")
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding()
                    Spacer()
                }
            }
            .onChange(of: selectedUsers, { oldValue, newValue in
                if let currentUser = self.user {
                    if !selectedUsers.isEmpty {
                        if selectedUsers.count == 1 {
                            for user in selectedUsers {
                                viewModel.createChat(groupName: "", groupProfileImage: nil, userIds: [user.id, currentUser.id], chatType: "Direct", createdBy: user.id, admins: [user.id, currentUser.id])
                            }
                        } else {
                            var userIds: [String] = [currentUser.id]
                            for user in selectedUsers {
                                userIds.append(user.id)
                            }
							viewModel.createChat(groupName: groupName, groupProfileImage: groupProfileImage, userIds: userIds, chatType: "Group", createdBy: currentUser.id, admins: [currentUser.id])
                        }
                    }
                }
                groupName = ""
                groupProfileImage = nil
                showChat = newValue != [User]()
            })
			.onChange(of: ChatViewModel.chatView, { oldValue, newValue in
				viewModel.observeRecentChats()
			})
            .navigationDestination(isPresented: $showChat, destination: {
                if let row = viewModel.recentChats.firstIndex(where: {$0.id == viewModel.newChatId}) {
					ChatView(chat: viewModel.recentChats[row])
                }
            })
            .sheet(isPresented:$showNewMessageView, content: {
                NewMessageView(selectedUsers: $selectedUsers, groupName: $groupName, groupProfileImage: $groupProfileImage)
            })
            .toolbar{
                ToolbarItem (placement: .navigationBarLeading){
                    HStack{
						if let currentUser = self.user {
							NavigationLink(destination: ProfileView(user: currentUser)) {
								CircularProfileImageView(profileImageUrl: currentUser.profileImageUrl, size: .xSmall)
							}
						}
                        
                        Text("Chats")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewMessageView.toggle()
                        selectedUsers = [User]()
                        viewModel.newChatId = ""
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
							.foregroundStyle(.white, .blue)
                    }
                }
            }
        }
    }
}

#Preview {
    InboxView()
}
