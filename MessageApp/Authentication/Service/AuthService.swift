//
//  AuthService.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthService {
    @Published var userSession: FirebaseAuth.User?
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        loadCurrentUserData()
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        NetworkManager.shared.isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            loadCurrentUserData()
        } catch {
            NetworkManager.shared.setError(error)
            print("DEBUG: Failed to sign in user with error \(error.localizedDescription)")
            return
        }
        NetworkManager.shared.isLoading = false
    }
    
    @MainActor
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        NetworkManager.shared.isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserData(email: email, fullname: fullname, id: result.user.uid)
            loadCurrentUserData()
        } catch {
            NetworkManager.shared.setError(error)
            print("Failed to create user with error: \(error.localizedDescription)")
            return
        }
        NetworkManager.shared.isLoading = false
    }
    
    func signOut() {
        NetworkManager.shared.isLoading = true
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            UserService.shared.currentUser = nil
        } catch {
            NetworkManager.shared.setError(error)
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            return
        }
        NetworkManager.shared.isLoading = false
    }
    
    func deleteAccount() {
        Task {
            NetworkManager.shared.isLoading = true
            do {
                guard let uid = Auth.auth().currentUser?.uid else { return }

                let storageReference = Storage.storage().reference().child("ProfileImages").child(uid)
                let profileImageExists = try await storageReference.listAll().items.count > 0


                if profileImageExists {
                    try await storageReference.delete()
                }

                let userDocumentReference = Firestore.firestore().collection("users").document(uid)
                try await userDocumentReference.delete()

                try await Auth.auth().currentUser?.delete()

                self.userSession = nil
                UserService.shared.currentUser = nil
            } catch {
                NetworkManager.shared.setError(error)
                print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
                return
            }
            NetworkManager.shared.isLoading = false
        }
    }
    
    private func uploadUserData(email: String, fullname: String, id: String) async throws {
        NetworkManager.shared.isLoading = true
        do {
            let user = User(fullname: fullname, email: email, profileImageUrl: nil)
            guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
            try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
        } catch {
            NetworkManager.shared.setError(error)
            print("DEBUG: Failed to upload user data with error: \(error.localizedDescription)")
            return
        }
        NetworkManager.shared.isLoading = false
    }
    
    private func loadCurrentUserData() {
        Task {
            NetworkManager.shared.isLoading = true
            try await UserService.shared.fetchCurrentUser()
            NetworkManager.shared.isLoading = false
        }
    }
}
