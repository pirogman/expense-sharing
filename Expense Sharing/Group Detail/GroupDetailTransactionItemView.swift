//
//  GroupDetailTransactionItemView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct UserExpenseView: View {
    let circleSize: CGFloat
    let expense: ExpenseWithInfo
    let currencyCode: String?
    
    var body: some View {
        HStack {
            Circle()
                .fill(expense.3)
                .squareFrame(side: circleSize)
            Text(expense.1)
            Spacer()
            let moneyText = CurrencyManager.getText(for: expense.2, currencyCode: currencyCode)
            Text(moneyText)
        }
        .lineLimit(1)
    }
}

struct GroupDetailTransactionItemView: View {
    let isSelected: Bool
    let description: String?
    let paidExpense: ExpenseWithInfo
    let otherExpenses: [ExpenseWithInfo]
    let currencyCode: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            UserExpenseView(circleSize: 12, expense: paidExpense, currencyCode: currencyCode)
                .font(.headline)
            Text(description?.hasText == true ? description! : "No description provided.")
                .font(.caption)
            
            if isSelected {
                VStack(spacing: 4) {
                    ForEach(otherExpenses, id: \.0) { expense in
                        UserExpenseView(circleSize: 8, expense: expense, currencyCode: currencyCode)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
