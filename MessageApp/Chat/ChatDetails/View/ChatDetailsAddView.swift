//
//  ChatDetailsAddView.swift
//  MessageApp
//
//  Created by Emir Okay on 4.03.2024.
//

import SwiftUI

struct ChatDetailsAddView: View {
	@ObservedObject var viewModel: ChatDetailsViewModel
	@Environment(\.dismiss) var dismiss
	
	@State private var selectedUsers = [User]()
	
    var body: some View {
		NavigationStack {
			VStack {
				TextField("Serch user..", text: $viewModel.searchText)
					.padding(8)
					.padding(.horizontal, 24)
					.background(Color(.tertiarySystemBackground))
					.cornerRadius(8)
					.overlay {
						HStack {
							Image(systemName: "magnifyingglass")
								.foregroundColor(.gray)
								.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
								.padding(.leading, 8)
						}
					}
					.padding()
				
				List {
					Section("Users"){
						ForEach(viewModel.searchableUsers) { user in
							VStack(alignment: .leading) {
								HStack {
									CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .small)
									
									VStack (alignment: .leading) {
										Text(user.fullname)
											.font(.callout)
											.fontWeight(.semibold)
										
										Text(user.email)
											.font(.subheadline)
											.foregroundColor(.gray)
									}
									
									Spacer()
									
									Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle")
										.foregroundColor(selectedUsers.contains(user) ? .blue : .gray)
								}
								.contentShape(Rectangle())

							}
							.onTapGesture {
								if selectedUsers.contains(user) {
									selectedUsers.removeAll(where: { $0 == user })
								} else {
									selectedUsers.append(user)
								}
							}
						}
					}
				}
				.padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
				.clipShape(Rectangle())
				
				Spacer()
				
				Button {
					viewModel.addToGroup(chatId: viewModel.chatId, selectedUsers: selectedUsers)
					dismiss()
				} label: {
					Text("Add to Group")
						.foregroundColor(.white)
						.padding()
						.background(Color.blue)
						.cornerRadius(8)
				}
				.padding()
			}
			.padding(.top, 4)
			.background(Color(.secondarySystemBackground))
			.navigationTitle("Add user")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel"){
						dismiss()
					}
					.foregroundColor(.red)
				}
				

			}
		}
    }
}

#Preview {
	ChatDetailsAddView(viewModel: ChatDetailsViewModel(chatId: "1"))
}
