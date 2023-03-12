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
    let paidAmount: Double
    let owedAmount: Double
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
                let paid = CurrencyManager.getText(for: paidAmount, currencyCode: currencyCode)
                Text(paid).font(.headline)
                
                let owed = CurrencyManager.getText(for: owedAmount, currencyCode: currencyCode)
                Text(owed).font(.subheadline)
            }
        }
        .lineLimit(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
