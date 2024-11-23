//
//  ChatView.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
	@StateObject var viewModel: ChatViewModel
	@State var showImagePicker = false
	@Namespace var bottomID
	@Environment(\.dismiss) var dismiss
	
	let chat: Chat
	
	init(chat: Chat) {
		self.chat = chat
		self._viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chat.id))
	}
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				VStack {
					ScrollView{
						
						ForEach(viewModel.messages) { message in
							ChatMessageCell(message: message)
						}
						
						Divider()
							.opacity(0)
							.id(bottomID)
					}
					
					Spacer()
					
					if let messageImage = viewModel.messageImage {
						messageImage
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(maxWidth: UIScreen.main.bounds.width - 20, maxHeight: UIScreen.main.bounds.height / 4)
							.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
							.overlay(alignment: .topTrailing) {
								Button {
									withAnimation(.easeInOut(duration: 0.25)) {
										viewModel.selectedItem = nil
										viewModel.messageImage = nil
									}
								} label: {
									ZStack {
										Circle()
											.frame(width: 32, height: 32)
											.foregroundColor(.black)
											.background(.black, in: Circle())
											.opacity(0.5)
										
										Image(systemName: "trash")
											.fontWeight(.bold)
											.foregroundColor(.red)
											.frame(width: 32, height: 32)
									}
								}
								.padding(10)
							}
					}
					
					HStack {
						
						Image(systemName: "photo.badge.plus")
							.padding(.leading)
							.onTapGesture {
								showImagePicker.toggle()
							}
							.photosPicker(isPresented: $showImagePicker, selection: $viewModel.selectedItem)
						
						ZStack(alignment: .trailing) {
							TextField("Message...", text: $viewModel.messageText, axis: .vertical)
								.padding(8)
								.padding(.trailing, 48)
								.background(Color(.systemGray5))
								.clipShape(ChatBuble(isFromCurrentUser: true))
								.font(.subheadline)
							
							Button {
								viewModel.sendMessage()
								viewModel.messageText = ""
								viewModel.selectedItem = nil
								viewModel.messageImage = nil
								viewModel.messageImageData = nil
							} label: {
								Text("Send")
									.fontWeight(.semibold)
							}
							.padding(.horizontal)
						}
						.padding()
					}
				}
				.onChange(of: viewModel.messages) { _, _ in
					withAnimation {
						proxy.scrollTo(bottomID)
					}
				}
				.onChange(of: viewModel.messageImage) { _, _ in
					withAnimation {
						proxy.scrollTo(bottomID)
					}
				}
				
			}
			.navigationBarBackButtonHidden(true)
			.onChange(of: ChatViewModel.chatView, { oldValue, newValue in
				dismiss()
			})
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					HStack {
						Button{
							dismiss()
						} label: {
							Image(systemName: "chevron.left")
						}
						.padding([.vertical, .leading], 4)
						
						if chat.type == "Direct" {
							if let user = chat.users?.first(where: { $0.id != UserService.shared.currentUser?.id }) {
								NavigationLink(destination: ProfileDetailsView(user: user)) {
									CircularProfileImageView(profileImageUrl: chat.type == "Group" ? URL(string: chat.chatProfileUrl ?? "") : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.profileImageUrl), size: .small)
									VStack(alignment: .leading) {
										Text(chat.type == "Group" ? chat.chatName : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.fullname ?? "Unknown"))
											.fontWeight(.semibold)
											.foregroundStyle(Color.primary)
										Text("Tap for more info")
											.font(.footnote)
											.foregroundStyle(.gray)
									}
								}
							}
						} else {
							NavigationLink(destination: ChatDetailsView(chatId: chat.id)) {
								CircularProfileImageView(profileImageUrl: chat.type == "Group" ? URL(string: chat.chatProfileUrl ?? "") : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.profileImageUrl), size: .small)
								VStack(alignment: .leading) {
									Text(chat.type == "Group" ? chat.chatName : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.fullname ?? "Unknown"))
										.fontWeight(.semibold)
										.foregroundStyle(Color.primary)
									Text("Tap for more info")
										.font(.footnote)
										.foregroundStyle(.gray)
								}
							}
						}
						
						
						
					}
				}
				
			}
			
			
		}
	}
}

#Preview {
	NavigationView{
		ChatView(chat: Chat(chatId: "1", chatName: "NewChat", chatBio: "bio", chatProfileUrl: "", participants: [User.MOCK_USER.id, User.MOCK_USER2.id, User.MOCK_USER3.id], type: "Direct", createdAt: Date(), createdBy: "1", admins: ["1"], updatedAt: Date()))
	}
}

