//
//  ChatDetailsEditView.swift
//  MessageApp
//
//  Created by Emir Okay on 6.03.2024.
//

import SwiftUI
import PhotosUI

struct ChatDetailsEditView: View {
	@ObservedObject var viewModel: ChatDetailsViewModel
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			VStack {
				PhotosPicker(selection: $viewModel.selectedItem) {
					if let profileImage = viewModel.groupProfileImage {
						profileImage
							.resizable()
							.scaledToFill()
							.frame(width: 80, height: 80)
							.clipShape(Circle())
					} else {
						CircularProfileImageView(profileImageUrl: URL(string: viewModel.chat?.chatProfileUrl ?? ""), size: .xLarge)
					}
				}
				.overlay(alignment: .bottomTrailing) {
					ZStack {
						Circle()
							.frame(width: 28, height: 28)
							.foregroundColor(.blue)
							.background(.black, in: Circle())
							.opacity(0.8)
		
						Image(systemName: "plus")
							.fontWeight(.bold)
							.foregroundColor(.white)
							.frame(width: 28, height: 28)
					}
				}
				
				Text("Edit Photo")
					.padding(4)
					.font(.subheadline)
				
				Text("Group Name")
					.font(.footnote)
					.foregroundColor(Color(.systemGray))
					.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
				
				TextField("New Group", text: $viewModel.groupName)
					.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
					.font(.subheadline)
					.padding(12)
					.background(Color(.tertiarySystemBackground))
					.cornerRadius (10)
					.padding(.horizontal, 24)

				
				Spacer()
			}
			.padding(.top)
			.background(Color(.secondarySystemBackground))
			.navigationTitle("Edit Group")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel"){
						dismiss()
					}
					.foregroundColor(.red)
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save"){
						viewModel.saveGroupInfo()
						dismiss()
					}
				}
			}
		}
    }
}

#Preview {
    ChatDetailsEditView(viewModel: ChatDetailsViewModel(chatId: "1"))
}
