//
//  NetworkStateManager.swift
//  MessageApp
//
//  Created by Emir Okay on 29.02.2024.
//

import Foundation

class NetworkManager: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    static let shared = NetworkManager()

    func setError(_ error: Error)  {
        
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        
    }
    
}
