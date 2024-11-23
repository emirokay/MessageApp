//
//  UserService.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserService {
    @Published var currentUser: User?
    static let shared = UserService()
    
    @MainActor
    func fetchCurrentUser() async throws {
        NetworkManager.shared.isLoading = true
        do {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let user = try snapshot.data(as: User.self)
            self.currentUser = user
        } catch {
            NetworkManager.shared.setError(error)
            print("DEBUG: Error fetching current user: \(error.localizedDescription)")
        }
        NetworkManager.shared.isLoading = false
    }
    
    static func fetchAllUsers() async throws -> [User] {
        NetworkManager.shared.isLoading = true
        let users: [User] = [User]()
        do {
            let snapshot = try await Firestore.firestore().collection("users").getDocuments()
            let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
            NetworkManager.shared.isLoading = false
            return users
        } catch {
            NetworkManager.shared.setError(error)
            print("DEBUG: Error fetching all users: \(error.localizedDescription)")
            return users
        }
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        FirestoreContents.UserCollection.document(uid).getDocument { snapshot, error in
            if let error = error {
                NetworkManager.shared.setError(error)
                print("DEBUG: Error fetching user with UID \(uid): \(error.localizedDescription)")
                return
            }
            guard let user = try? snapshot?.data(as: User.self) else { return }
            completion(user)
        }
    }
    
    func saveProfile(fullname: String, email: String, bio: String, profileImageData: Data?) {
        Task {
            NetworkManager.shared.isLoading = true

            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            
            let currentUserRef = FirestoreContents.UserCollection.document(currentUid)
            let currentUserStorageRef = Storage.storage().reference().child("ProfileImages").child(currentUid)
            
            var user = User(fullname: fullname, email: email , bio: bio)
            
            if let profileImageData = profileImageData{
                do {
                    let _ = try await currentUserStorageRef.putDataAsync(profileImageData)
                    let downloadURL = try await currentUserStorageRef.downloadURL()
                    user.profileImageUrl = downloadURL
                } catch {
                    NetworkManager.shared.setError(error)
                    print("DEBUG: Failed to upload profile image: \(error.localizedDescription)")
                    return
                }
            } else {
                user.profileImageUrl = currentUser?.profileImageUrl
            }
            
            do {
                let userData = try Firestore.Encoder().encode(user)
                try await currentUserRef.setData(userData)
                try await fetchCurrentUser()
            } catch {
                NetworkManager.shared.setError(error)
                print("DEBUG: Failed to save user data: \(error.localizedDescription)")
            }
            NetworkManager.shared.isLoading = false
        }
    }
    
}
