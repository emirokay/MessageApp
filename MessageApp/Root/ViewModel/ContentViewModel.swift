//
//  ContentViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Firebase
import FirebaseAuth
import Combine

@MainActor
class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    private var cancellables = Set<AnyCancellable>()
        
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        AuthService.shared.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userSession in
            self?.userSession = userSession
        }.store(in: &cancellables)
        
        Publishers.CombineLatest3(
            NetworkManager.shared.$isLoading,
            NetworkManager.shared.$showError,
            NetworkManager.shared.$errorMessage
        )
        .receive(on: DispatchQueue.main)
        .sink { isLoading, showError, errorMessage in
            self.isLoading = isLoading
            self.showError = showError
            self.errorMessage = errorMessage
        }
        .store(in: &cancellables)
    }
}



//NetworkStateManager.shared.isLoading = true
//await NetworkStateManager.shared.setError(error)
//NetworkStateManager.shared.isLoading = false
