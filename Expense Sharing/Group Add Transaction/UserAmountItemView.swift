//
//  UserAmountItemView.swift
//  Expense Sharing
//

import SwiftUI

struct UserAmountItemView: View {
    let user: User
    let amount: Double
    let currencyCode: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
            }
            Spacer()
            let moneyText = CurrencyManager.getText(for: amount, currencyCode: currencyCode)
            Text(moneyText)
                .bold()
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
    }
}
