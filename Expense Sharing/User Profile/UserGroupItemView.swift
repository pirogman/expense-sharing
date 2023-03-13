//
//  UserGroupItemView.swift
//  Expense Sharing
//

import SwiftUI

struct UserGroupItemView: View {
    let groupTitle: String
    let groupUsersCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(groupTitle)
                    .font(.headline)
                Text("\(groupUsersCount) user(s)")
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable().scaledToFit()
                .squareFrame(side: 12)
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}
