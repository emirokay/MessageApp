//
//  ContentView.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                InboxView()
            } else {
                LoginView()
            }
        }
        .overlay {
            LoadingView(show: $viewModel.isLoading)
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ContentView()
}
