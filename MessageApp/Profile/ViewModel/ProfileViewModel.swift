//
//  ProfileViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 17.02.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var bio = ""
    @Published var email = ""

    @Published var profileImage: Image?
    @Published var profileImageData: Data?
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let service = UserService.shared
    
    @Published var currentUser: User?
    init() {
        setupSubscribers()
        if let user = service.currentUser {
            self.currentUser = user
        }
        self.fullName = service.currentUser?.fullname ?? ""
        self.bio = service.currentUser?.bio ?? ""
        self.email = service.currentUser?.email ?? ""
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }.store(in: &cancellables)
    }
    
    func loadImage() async throws {
        guard let item =  selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        self.profileImageData = imageData
        guard let uiImage = UIImage(data: imageData) else { return }
        self.profileImage = Image(uiImage: uiImage)
    }
    
    func saveProfile() {
        if fullName != "" {
            service.saveProfile(fullname: fullName,email: email, bio: bio, profileImageData: profileImageData)
            profileImageData = nil
            selectedItem = nil
        }
    }
    
}
