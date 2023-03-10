//
//  SearchUserItemView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI

struct SearchUserItemView: View {
    let user: User
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .resizable().scaledToFit()
                .squareFrame(side: 20)
                .padding(2)
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
            }
            Spacer()
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}
