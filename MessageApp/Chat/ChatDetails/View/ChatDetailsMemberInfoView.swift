//
//  ChatDetailsMemberInfoView.swift
//  MessageApp
//
//  Created by Emir Okay on 7.03.2024.
//

import SwiftUI

struct ChatDetailsMemberInfoView: View {
	@ObservedObject var viewModel: ChatDetailsViewModel
	@Environment(\.dismiss) var dismiss
	var user: User
	
	var body: some View {
		NavigationStack {
			VStack {
				HStack {
					CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .small)
					Text(user.fullname)
					
					Spacer()
					
					Image(systemName: "circle.fill")
						.resizable()
						.frame(width: 25, height: 25)
						.foregroundStyle(Color(.systemGray3))
						.overlay{
							Image(systemName: "plus")
								.rotationEffect(.degrees(45))
								.fontWeight(.bold)
								.foregroundStyle(Color(.systemGray))
								.onTapGesture {
									dismiss()
								}
						}
				}
				
				Button(action: {
					viewModel.showProfileDetails.toggle()
					dismiss()
				}) {
					Text("Info")
						.frame(maxWidth: .infinity)
				}
				.padding()
				.background(Color(.tertiarySystemBackground))
				.cornerRadius(10)
				
				VStack {
					Button{
						viewModel.admin(userId: user.id)
						dismiss()
					} label: {
						if let chat = viewModel.chat {
							Text(chat.admins.contains(user.id) ? "Dismiss as Admin" : "Make Admin" )
								.frame(maxWidth: .infinity)
								.foregroundStyle(chat.admins.contains(user.id) ? .red : .blue)
						}
					}
					.padding(4)
					Divider()
					Button{
						viewModel.removeFromGroup(userId: user.id)
						dismiss()
					} label: {
						Text("Remove from group")
							.frame(maxWidth: .infinity)
							.foregroundStyle(.red)
					}
					.padding(4)
				}
				.padding()
				.background(Color(.tertiarySystemBackground))
				.cornerRadius(10)
				Spacer()
			}
			.padding()
			.ignoresSafeArea(.container, edges: .bottom)
			.background(Color(.secondarySystemBackground))
		}
		
    }
}

#Preview {
	ChatDetailsMemberInfoView(viewModel: ChatDetailsViewModel(chatId: "1"), user: User.MOCK_USER)
}
