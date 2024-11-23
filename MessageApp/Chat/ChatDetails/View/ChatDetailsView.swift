//
//  ChatDetailsView.swift
//  MessageApp
//
//  Created by Emir Okay on 3.03.2024.
//

import SwiftUI

struct ChatDetailsView: View {
	
	@StateObject var viewModel: ChatDetailsViewModel
	@State private var selectedUser: User? = nil
	@State private var isProfileSheetPresented = false
	@State private var exitGroup = false
	@Environment(\.presentationMode) var presentationMode
	let chatId: String
	
	init(chatId: String) {
		self.chatId = chatId
		self._viewModel = StateObject(wrappedValue: ChatDetailsViewModel(chatId: chatId))
	}
	
	var body: some View {
		NavigationStack {
			if let chat = viewModel.chat {
				ScrollView {
					VStack{
						CircularProfileImageView(profileImageUrl: URL(string: chat.chatProfileUrl ?? ""), size: .xLarge)
						
						Text(chat.chatName)
							.font(.title2)
							.fontWeight(.semibold)
						
						Text("Created by \(viewModel.createdBy)")
							.font(.footnote)
							.foregroundStyle(.gray)
						
						Text("Created \(chat.createdAt.dateString())")
							.font(.footnote)
							.foregroundStyle(.gray)
						
						Text("Biography")
							.font(.footnote)
							.foregroundColor(Color(.systemGray))
							.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
						
						Button{
							viewModel.showAddChatBioView.toggle()
						}label: {
							HStack {
								Text(chat.chatBio == "" ? "Add group bio" : chat.chatBio)
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundStyle(.gray)
							}
						}
						.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
						.font(.subheadline)
						.padding(12)
						.background(Color(.systemGray6))
						.cornerRadius (10)
						.padding(.horizontal, 24)
						.foregroundStyle(chat.chatBio == "" ? .gray : .primary)
						
						Text("Users")
							.font(.footnote)
							.foregroundColor(Color(.systemGray))
							.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
						
						if let users = viewModel.chat?.users {
							VStack(alignment: .leading) {
								
								Button{
									viewModel.showChatAddView.toggle()
								} label: {
									HStack {
										Image(systemName: "plus.circle.fill")
											.resizable()
											.frame(width: 40, height: 40)
											.foregroundStyle(.blue)
										
										Text("Add Members")
											.font(.callout)
											.fontWeight(.semibold)
											.foregroundStyle(Color.primary)
										
										Spacer()
										Image(systemName: "chevron.right")
											.foregroundStyle(.gray)
									}
									.contentShape(Rectangle())
									.padding(4)
								}
								
								Divider()
								
								NavigationLink(destination: ProfileView(user: viewModel.currUser)) {
									HStack {
										CircularProfileImageView(profileImageUrl: viewModel.currUser.profileImageUrl, size: .small)
										VStack (alignment: .leading) {
											Text("\(viewModel.currUser.fullname) (You)")
												.font(.callout)
												.fontWeight(.semibold)
												.foregroundStyle(Color.primary)
											
											Text(viewModel.currUser.email)
												.font(.subheadline)
												.foregroundColor(.gray)
										}
										Spacer()
										if (chat.admins.contains(viewModel.currUser.id)) {
											Text("(Admin)")
												.font(.subheadline)
												.foregroundColor(.gray)
										}
										Image(systemName: "chevron.right")
											.foregroundStyle(.gray)
									}
									.contentShape(Rectangle())
									.padding(4)
								}
								
								
								ForEach(users) { user in
									if user != viewModel.currUser {
										
										Divider()
										Button{
											selectedUser = user
											viewModel.showMemberInfo.toggle()
										} label: {
											HStack {
												CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .small)
												
												VStack (alignment: .leading) {
													Text(user.fullname)
														.font(.callout)
														.fontWeight(.semibold)
														.foregroundStyle(Color.primary)
													
													Text(user.email)
														.font(.subheadline)
														.foregroundStyle(.gray)
												}
												Spacer()
												if chat.admins.contains(user.id) {
													Text("(Admin)")
														.font(.subheadline)
														.foregroundColor(.gray)
												}
												Image(systemName: "chevron.right")
													.foregroundStyle(.gray)
											}
											.contentShape(Rectangle())
											.padding(4)
										}
										
									}
								}
							}
							.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
							.padding(12)
							.background(Color(.systemGray6))
							.cornerRadius (10)
							.padding(.horizontal, 24)
						}
						
						Button {
							viewModel.removeFromGroup(userId: viewModel.currUser.id)
							ChatViewModel.chatView.toggle()
							presentationMode.wrappedValue.dismiss()
						} label: {
							Text("Exit Group")
								.frame(maxWidth: UIScreen.main.bounds.width - 60)
								.foregroundStyle(.red)
						}
						.padding(12)
						.background(Color(.systemGray6))
						.cornerRadius(10)
						.padding(.horizontal, 24)
						
						Spacer()
					}
					
				}
				.scrollBounceBehavior(.basedOnSize)
				.sheet(isPresented: $viewModel.showEditChatView, content: {
					ChatDetailsEditView(viewModel: viewModel)
				})
				.sheet(isPresented: $viewModel.showAddChatBioView, content: {
					ChatDetailsAddBioView(viewModel: viewModel)
				})
				.sheet(isPresented:$viewModel.showChatAddView, content: {
					ChatDetailsAddView(viewModel: viewModel)
				})
				.sheet(isPresented: $viewModel.showMemberInfo, content: {
					if let user = selectedUser {
						ChatDetailsMemberInfoView(viewModel: viewModel, user: user)
							.presentationDetents([.height(230)])
							.presentationDragIndicator(.hidden)
							.onDisappear {
								viewModel.showMemberInfo = false
								if viewModel.showProfileDetails == true {
									isProfileSheetPresented = true
								}
							}
					}
				})
				.sheet(isPresented: $isProfileSheetPresented, content: {
					if let user = selectedUser {
						ProfileDetailsView(user: user)
							.onDisappear {
								viewModel.showProfileDetails = false
							}
					}
				})
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Button("Edit"){
							viewModel.showEditChatView.toggle()
						}
					}
				}
			}
		}
		
	}
}



#Preview {
	NavigationStack {
		ChatDetailsView(chatId: "1")
	}
}

