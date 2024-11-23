//
//  ProfileService.swift
//  MessageApp
//
//  Created by Emir Okay on 20.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

struct ProfileService {
    let user: User
    
    func saveProfile(user: User, fullname: String, bio: String, profileImageData: Data?) {
        Task {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
            let currentUserRef = FirestoreContents.UserCollection.document(currentUid)
            let currentUserStorageRef = Storage.storage().reference().child("ProfileImages").child(currentUid)
            
            var user = User(fullname: fullname, email: user.email, bio: bio)
            
            do {
                if let profileImageData = profileImageData {
                    let _ = try await currentUserStorageRef.putDataAsync(profileImageData)
                    let downloadURL = try await currentUserStorageRef.downloadURL()
                    user.profileImageUrl = downloadURL
                }
                
                let userData = try Firestore.Encoder().encode(user)
                try await currentUserRef.setData(userData)
            } catch {
                // Set custom error and handle it using NetworkManager.shared.setError(customError)
                let customError = NSError(domain: "YourDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to save profile"])
                NetworkManager.shared.setError(customError)
                print("DEBUG: Failed to save profile with error: \(error.localizedDescription)")
            }
        }
    }
    
}
