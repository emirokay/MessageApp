//
//  ChatDetailsAddBioView.swift
//  MessageApp
//
//  Created by Emir Okay on 6.03.2024.
//

import SwiftUI

struct ChatDetailsAddBioView: View {
	@ObservedObject var viewModel: ChatDetailsViewModel
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			VStack(alignment: .leading) {
				
				ScrollView {
					TextEditor(text: $viewModel.groupBio)
						.foregroundColor(viewModel.groupBio == viewModel.placeHolderText ? .secondary : .primary)
						.onTapGesture {
						  if viewModel.groupBio == viewModel.placeHolderText {
							  viewModel.groupBio = ""
						  }
						}
						.padding(4)
						.frame(maxWidth: UIScreen.main.bounds.width - 60, minHeight: UIScreen.main.bounds.height / 5)
						.textEditorStyle(PlainTextEditorStyle())
						.background(Color(.tertiarySystemBackground))
						.cornerRadius(10)
						.padding(.horizontal, 24)
				}
				
				Spacer()
			}
			.padding(.top)
			.background(Color(.secondarySystemBackground))
			.navigationTitle("Group bio")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel"){
						dismiss()
					}
					.foregroundColor(.red)
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button("Save"){
						viewModel.saveGroupBio()
						dismiss()
					}
				}
			}
		}
    }
}

#Preview {
	ChatDetailsAddBioView(viewModel: ChatDetailsViewModel(chatId: "1"))
}
