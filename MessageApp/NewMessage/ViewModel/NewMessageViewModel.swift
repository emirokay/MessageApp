//
//  NewMessageViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import Firebase
import FirebaseAuth
import SwiftUI
import PhotosUI

class NewMessageViewModel: ObservableObject {
    @Published var users = [User]()
    
    @Published var groupProfileImage: Image?
    @Published var groupProfileImageData: Data?
    
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    @Published var searchText = ""
    @Published var groupName = ""
    
    init() {
        Task { try await fetchUsers() }
    }
    
    var searchableUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            let lowercasedQuery = searchText.lowercased()
            return users.filter {
                $0.fullname.lowercased().contains(lowercasedQuery) || $0.email.lowercased().contains(lowercasedQuery)
            }
        }
    }
    
    func loadImage() async throws {
        guard let item =  selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        self.groupProfileImageData = imageData
        guard let uiImage = UIImage(data: imageData) else { return }
        self.groupProfileImage = Image(uiImage: uiImage)
    }
    
    func fetchUsers() async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let users = try await UserService.fetchAllUsers()
        await MainActor.run {
            self.users = users.filter({ $0.id != currentUid })
        }
    }
    
}
