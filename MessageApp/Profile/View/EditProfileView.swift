//
//  EditProfileView.swift
//  MessageApp
//
//  Created by Emir Okay on 20.02.2024.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    //@State var showImagePicker = false
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ProfileViewModel()
    let user: User
    var body: some View {
        NavigationStack {
            VStack{
                    PhotosPicker(selection: $viewModel.selectedItem) {
                        if let profileImage = viewModel.profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        } else {
                            CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .xLarge)
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
                
                Divider()
                    .padding(.horizontal)
                HStack(alignment: .center) {
                    TextField("Enter your name", text: $viewModel.fullName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                    
                Divider()
                    .padding(.horizontal)
                
                Text("Add Biography")
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray))
                    .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                
                TextField("Something about you?", text: $viewModel.bio, axis: .vertical)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius (10)
                    .padding(.horizontal, 24)

                VStack {
                    Text("Personal Information")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                    Divider()
                        .padding([.horizontal, .bottom])
                    
                    Text("Email")
                        .font(.footnote)
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                    
                    Text(user.email)
                        .frame(width: UIScreen.main.bounds.width - 70, alignment: .leading)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius (10)
                        .padding(.horizontal, 24)
                    
                }
                .padding()
             
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save"){
                        viewModel.saveProfile()
                        dismiss()
                    }
                }
                
            }
			.navigationBarBackButtonHidden()
        }
    }
    
}

#Preview {
    NavigationStack {
        EditProfileView(viewModel: ProfileViewModel(), user: User.MOCK_USER)
    }
}
