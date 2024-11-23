//
//  RegisterViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullname = ""
    
    func createUser() async throws {
        try await AuthService.shared.createUser(withEmail: email, password: password, fullname: fullname)
    }
}

