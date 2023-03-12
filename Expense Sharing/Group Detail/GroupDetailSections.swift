//
//  GroupDetailSections.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

// MARK: - Chats Section

struct GroupDetailChartView: View {
    let centerText: String
    
    var body: some View {
        HStack {
            Spacer()
            Circle()
                .foregroundColor(.red)
                .squareFrame(side: UIScreen.main.bounds.width * 0.6)
                .overlay(
                    Text(centerText).bold()
                        .squareFrame(side: UIScreen.main.bounds.width * 0.35)
                        .background(
                            Circle().foregroundColor(.white)
                        )
                )
            Spacer()
        }
    }
}

// MARK: - Users Section

struct GroupDetailUserView: View {
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

// MARK: - Transactions Section

struct UserExpenseView: View {
    let userName: String
    let amount: Double
    let currencyCode: String?
    
    var body: some View {
        HStack {
            Text(userName)
            Spacer()
            let moneyText = CurrencyManager.getText(for: amount, currencyCode: currencyCode)
            Text(moneyText)
        }
        .lineLimit(1)
    }
}

struct GroupDetailTransactionView: View {
    let isSelected: Bool
    let description: String?
    let paidUserName: String
    let paidAmount: Double
    let currencyCode: String?
    let expenses: [(String, String, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            UserExpenseView(userName: paidUserName, amount: paidAmount, currencyCode: currencyCode)
                .font(.headline)
            Text(description?.hasText == true ? description! : "No description provided.")
                .font(.caption)
            
            if isSelected {
                VStack(spacing: 4) {
                    ForEach(expenses, id: \.0) { expense in
                        HStack {
                            Circle().fill()
                                .squareFrame(side: 8)
                            UserExpenseView(userName: expense.1, amount: expense.2, currencyCode: currencyCode)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
