//
//  NewGroupView.swift
//  MessageApp
//
//  Created by Emir Okay on 27.02.2024.
//

import SwiftUI
import PhotosUI

struct NewGroupView: View {
    @StateObject private var viewModel = NewMessageViewModel()
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedUsers: [User]
    @Binding var groupName: String
    @Binding var groupProfileImage: Data?
    
    @State var preSelectedUsers: [User] = [User]()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    PhotosPicker(selection: $viewModel.selectedItem) {
                        if let profileImage = viewModel.groupProfileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        } else {
                            CircularProfileImageView(profileImageUrl: URL(string: ""), size: .medium)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                                .background(.black, in: Circle())
                                .opacity(0.8)
            
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                        }
                    }
                        
                    TextField("Enter Group Name", text: $viewModel.groupName)
                        .font (.subheadline)
                        .padding(12)
						.background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
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
                                    
                                    Image(systemName: preSelectedUsers.contains(user) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(preSelectedUsers.contains(user) ? .blue : .gray)
                                }
                                .contentShape(Rectangle())

                            }
                            .onTapGesture {
                                if preSelectedUsers.contains(user) {
                                    preSelectedUsers.removeAll(where: { $0 == user })
                                } else {
                                    preSelectedUsers.append(user)
                                }
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
                .clipShape(Rectangle())
                
                Spacer()
                
                Button {
                    selectedUsers = preSelectedUsers
                    groupName = viewModel.groupName.isEmpty ? "New Group" : viewModel.groupName
                    if let image = viewModel.groupProfileImageData {
                        groupProfileImage = image
                    }
                    dismiss()
                } label: {
                    Text("Create Group")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewGroupView(selectedUsers: .constant([User.MOCK_USER, User.MOCK_USER2, User.MOCK_USER3]), groupName: .constant("fuckMyLife"), groupProfileImage: .constant(Data()))
}



    
