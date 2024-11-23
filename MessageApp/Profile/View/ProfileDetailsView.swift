//
//  ProfileDetailsView.swift
//  MessageApp
//
//  Created by Emir Okay on 3.03.2024.
//

import SwiftUI

struct ProfileDetailsView: View {
	@Environment(\.dismiss) var dismiss
	var user: User
	
	var body: some View {
		NavigationStack {
			VStack{
				CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .xLarge)
				
				
				Text(user.fullname)
					.font(.title2)
					.fontWeight(.semibold)
				
				Text(user.email)
					.font(.footnote)
					.foregroundStyle(.gray)
				
				
				if let bio = user.bio {
					Text("Biography")
						.font(.footnote)
						.foregroundColor(Color(.systemGray))
						.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
					
					Text(bio)
						.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
						.font(.subheadline)
						.padding(12)
						.background(Color(.tertiarySystemBackground))
						.cornerRadius (10)
						.padding(.horizontal, 24)
				}
				
				HStack(alignment: .center) {
					Button {
						//Send message to this user
					} label: {
						VStack {
							Image(systemName: "message.circle.fill")
								.resizable()
								.frame(maxWidth: UIScreen.main.bounds.width / 10, maxHeight: UIScreen.main.bounds.width / 10)
							Text("Send Message")
						}
						.frame(maxWidth: UIScreen.main.bounds.width / 2.8)
						.padding(12)
						.background(Color(.tertiarySystemBackground))
						.cornerRadius (10)
						
					}
					
					Button {
						//Search in chat
					} label: {
						VStack {
							Image(systemName: "magnifyingglass.circle.fill")
								.resizable()
								.frame(maxWidth: UIScreen.main.bounds.width / 10, maxHeight: UIScreen.main.bounds.width / 10)
							Text("Search")
						}
						.frame(maxWidth: UIScreen.main.bounds.width / 2.8)
						.padding(12)
						.background(Color(.tertiarySystemBackground))
						.cornerRadius (10)
						
					}
				}
				Spacer()
			}
			.padding(.top)
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "chevron.left")
						Text("Back")
					}
				}
				
			}
			.background(Color(.secondarySystemBackground))
		}
	}
}

#Preview {
	ProfileDetailsView(user: User.MOCK_USER)
}
