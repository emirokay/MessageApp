//
//  NewMessageView.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import SwiftUI

struct NewMessageView: View {
    @StateObject private var viewModel = NewMessageViewModel()
    @Binding var selectedUsers: [User]
    @Binding var groupName: String
    @Binding var groupProfileImage: Data?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Serch user..", text: $viewModel.searchText)
                    .padding(8)
                    .padding(.horizontal, 24)
					.background(Color(.secondarySystemBackground))
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
                                }
                                .contentShape(Rectangle())
                            }
                            .onTapGesture {
                                selectedUsers.append(user)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
                .clipShape(Rectangle())
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        NewGroupView(selectedUsers: $selectedUsers, groupName: $groupName, groupProfileImage: $groupProfileImage)
                    } label: {
                        Text("New Group")
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .onChange(of: selectedUsers) { oldValue, newValue in
                dismiss()
            }
            
        }
    }
}

#Preview {
    NavigationStack{
        NewMessageView(selectedUsers: .constant([User.MOCK_USER, User.MOCK_USER2, User.MOCK_USER3]), groupName: .constant("fuckMyLife"), groupProfileImage: .constant(Data()))
    }
}
