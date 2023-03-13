//
//  SearchUserItemView.swift
//  Expense Sharing
//

import SwiftUI

struct SearchUserItemView: View {
    let isSelected: Bool
    let userName: String
    let userEmail: String
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .resizable().scaledToFit()
                .squareFrame(side: 20)
                .padding(2)
            VStack(alignment: .leading, spacing: 6) {
                Text(userName)
                    .font(.headline)
                Text(userEmail)
                    .font(.subheadline)
            }
            Spacer()
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}
