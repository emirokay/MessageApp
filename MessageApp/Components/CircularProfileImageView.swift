//
//  CircularProfileImageView.swift
//  MessageApp
//
//  Created by Emir Okay on 18.02.2024.
//

import SwiftUI
import SDWebImageSwiftUI

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    
    var dimension: CGFloat {
        switch self {
        case .xxSmall: return 28
        case .xSmall: return 32
        case .small: return 40
        case .medium: return 56
        case .large: return 64
        case .xLarge: return 80
        }
    }
}

struct CircularProfileImageView: View {
    var profileImageUrl: URL?
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = profileImageUrl {
            WebImage(url: imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
				.overlay{
					Circle()
						.stroke(style: StrokeStyle())
						.foregroundStyle(Color(.systemGray3))
				}
        } else {
            Image("nullProfile")
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
				.overlay{
					Circle()
						.stroke(style: StrokeStyle())
						.foregroundStyle(Color(.systemGray3))
				}
        }
    }
}

#Preview {
    CircularProfileImageView(profileImageUrl: URL(string: ""), size: .medium)
}
