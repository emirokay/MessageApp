//
//  InboxRowView.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import SwiftUI

struct InboxRowView: View {
    let chat: Chat
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CircularProfileImageView(profileImageUrl: chat.type == "Group" ? URL(string: chat.chatProfileUrl ?? "") : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.profileImageUrl), size: .medium)
            
            VStack(alignment: .leading, spacing: 4){
                Text(chat.type == "Group" ? chat.chatName : (chat.users?.first(where: { $0.uid != UserService.shared.currentUser?.uid })?.fullname ?? "Unknown"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(chat.lastMessage ?? "")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
            }
            
            HStack {
                Text(chat.updatedAt.timestampString())
                Image(systemName: "chevron.right")
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .frame(height: 72)
        .contentShape(Rectangle())
    }
}

//#Preview {
//    InboxRowView()
//}
