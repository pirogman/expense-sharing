//
//  UserAmountItemView.swift
//  Expense Sharing
//

import SwiftUI

struct UserAmountItemView: View {
    let userName: String
    let userEmail: String
    let amount: Double
    let currencyCode: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(userName)
                    .font(.headline)
                Text(userEmail)
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
