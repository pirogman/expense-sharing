//
//  NewGroupMemberItemView.swift
//  Expense Sharing
//

import SwiftUI

struct NewGroupMemberItemView: View {
    let userName: String
    let userEmail: String
    
    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .resizable().scaledToFit()
                .squareFrame(side: 16)
                .padding(4)
            VStack(alignment: .leading, spacing: 6) {
                Text(userName)
                    .font(.headline)
                Text(userEmail)
                    .font(.subheadline)
            }
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.white)
        }
    }
}
