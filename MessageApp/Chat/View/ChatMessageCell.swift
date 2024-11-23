//
//  ChatMessageCell.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatMessageCell: View {
	let message: Message
	private var isFromCurrentUser: Bool {
		return message.isFromCurrentUser
	}
	
	var body: some View {
		HStack {
			if isFromCurrentUser {
				Spacer()
				VStack {
					if let downloadURL = message.downloadURL, !downloadURL.isEmpty {
						if let image = message.downloadURL {
//							WebImage(url: URL(string: image)).placeholder {
//								ProgressView()
//									.frame(maxWidth: UIScreen.main.bounds.width / 1.35, maxHeight: UIScreen.main.bounds.height / 4, alignment: .center)
//									.overlay {
//										Rectangle()
//											.background(.gray)
//											.opacity(0.2)
//									}
//							}
//							.resizable()
//							.aspectRatio(contentMode: .fill)
//							.frame(maxWidth: UIScreen.main.bounds.width / 1.35, maxHeight: UIScreen.main.bounds.height / 4, alignment: .center)
//							.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//							.padding([.horizontal, .top], 8)
						}
					}
						
					

					if message.content != "" {
						Text(message.content)
							.font(.subheadline)
							.padding(12)
							.foregroundColor(.white)
							.background(Color(.systemBlue))
							.clipShape(ChatBuble(isFromCurrentUser: true))
							.frame(maxWidth: UIScreen.main.bounds.width / 1.35, alignment: .trailing)
					}
				}
				
				
			} else {
				HStack(alignment: .bottom, spacing: 8){
					//CircularProfileImageView(user: message., size: .xxSmall)
					VStack{
						if let downloadURL = message.downloadURL, !downloadURL.isEmpty {
							if let image = message.downloadURL {
//								WebImage(url: URL(string: image)).placeholder {
//									ProgressView()
//										.frame(maxWidth: UIScreen.main.bounds.width / 1.35, maxHeight: UIScreen.main.bounds.height / 4, alignment: .center)
//										.overlay {
//											Rectangle()
//												.background(.gray)
//												.opacity(0.2)
//										}
//										
//								}
//								.resizable()
//								.aspectRatio(contentMode: .fill)
//								.frame(maxWidth: UIScreen.main.bounds.width / 1.35, maxHeight: UIScreen.main.bounds.height / 4, alignment: .center)
//								.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//								.padding([.horizontal, .top], 8)
							}
						}
						if message.content != "" {
							Text(message.content)
								.font(.subheadline)
								.padding(12)
								.foregroundColor(Color.primary)
								.background(Color(.systemGray5))
								.clipShape(ChatBuble(isFromCurrentUser: false))
								.frame(maxWidth: UIScreen.main.bounds.width / 1.35, alignment: .leading)
						}
					}
					Spacer()
				}
			}
		}
		.onChange(of: message.downloadURL, { oldValue, newValue in
			
		})
		.padding(.horizontal, 8)
	}
}
