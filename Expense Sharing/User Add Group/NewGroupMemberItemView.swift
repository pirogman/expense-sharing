//
//  NewGroupMemberItemView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI

struct NewGroupMemberItemView: View {
    let user: User
    
    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .resizable().scaledToFit()
                .squareFrame(side: 16)
                .padding(4)
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
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
