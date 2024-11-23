//
//  ProfileView.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
//    @State var showEditProfile = false
    @StateObject var viewModel = ProfileViewModel()
    
    var user: User
	
    var body: some View {
        VStack{
			CircularProfileImageView(profileImageUrl: user.profileImageUrl, size: .xLarge)
            
			Text(user.fullname)
				.font(.title2)
				.fontWeight(.semibold)
            
			if let bio = user.bio {
                Text("Biography")
                    .font(.footnote)
                    .foregroundColor(Color(.systemGray))
                    .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                
                Text(bio)
                    .frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius (10)
                    .padding(.horizontal, 24)
            }
        }
        
        List {
            Section {
                ForEach(SettingsOptionsViewModel.allCases) { option in
                    HStack {
                        Image(systemName: option.imageName)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(option.imageBackgroundColor)
                        
                        Text(option.title)
                            .font(.subheadline)
                    }
                }
            }
            
            Section {
                Button("Log out"){
                    AuthService.shared.signOut()
                }
                
                Button("Delete Account") {
                    AuthService.shared.deleteAccount()
                }
            }
            .foregroundColor(.red)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
				NavigationLink(destination:  EditProfileView(user: user)) {
					Text("Edit Profile")
				}
//                Button("Edit Profile"){
//                    showEditProfile.toggle()
//                }
            }
        }
//        .fullScreenCover(isPresented: $showEditProfile){
//                EditProfileView(user: user)
//        }
        
    }
    
}

#Preview {
    NavigationStack {
		ProfileView(user: User.MOCK_USER)
    }
}
