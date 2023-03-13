//
//  GroupDetailUserItemView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct GroupDetailUserItemView: View {
    let color: Color
    let userName: String
    let userEmail: String
    let amount: Double
    let currencyCode: String?
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(color)
                .squareFrame(side: 24)
            VStack(alignment: .leading, spacing: 6) {
                Text(userName).font(.headline)
                Text(userEmail).font(.subheadline)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                let moneyText = CurrencyManager.getText(for: amount, currencyCode: currencyCode)
                if amount > 0 {
                    Text(moneyText).font(.headline)
                    Text("owed").font(.subheadline)
                } else if amount < 0 {
                    Text(moneyText).font(.headline)
                    Text("owes").font(.subheadline)
                } else {
                    Text(moneyText).font(.headline)
                }
            }
        }
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
