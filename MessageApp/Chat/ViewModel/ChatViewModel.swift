//
//  ChatViewModel.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [Message]()
    
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try await loadImage() } }
    }
    @Published var messageImage: Image?
    @Published var messageImageData: Data?
    
	static var chatView = true
	
    let service: ChatService
    let chatId: String
    
    init(chatId: String) {
        self.chatId = chatId
        self.service = ChatService(chatId: chatId)
        observeMessages()
    }
    
    func loadImage() async throws {
        guard let item =  selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        self.messageImageData = imageData
        guard let uiImage = UIImage(data: imageData) else { return }
        self.messageImage = Image(uiImage: uiImage)
    }
    
    func observeMessages() {
        service.observeMessages() { messages in
            for message in messages {
                if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                    self.messages[index] = message
                } else {
                    self.messages.append(message)
                }
            }
        }
    }
    
    func sendMessage() {
        if messageText != "" || messageImageData != nil{
            service.sendMessage(messageContent: messageText, messageImageData: messageImageData)
        }
    }
}
