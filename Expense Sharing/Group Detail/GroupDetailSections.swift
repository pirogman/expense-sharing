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
    let user: ManagedUser
    let money: Double
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.red)
                .squareFrame(side: 24)
            Text(user.name)
                .font(.headline)
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            let moneyText = CurrencyManager.getText(for: money)
            Text(moneyText)
        }
        .lineLimit(1)
    }
}

// MARK: - Transactions Section

struct UserExpenseView: View {
    let expense: Expense
    
    init(_ expense: Expense) {
        self.expense = expense
    }
    
    var body: some View {
        HStack {
            Text(expense.user.name)
            Spacer()
            let moneyText = CurrencyManager.getText(for: expense.money)
            Text(moneyText)
        }
        .lineLimit(1)
    }
}

struct GroupDetailTransactionView: View {
    let transaction: ManagedTransaction
    
    @Binding var selectedTransactionId: String?
    
    init(_ transaction: ManagedTransaction, selectedId: Binding<String?> = .constant(nil)) {
        self.transaction = transaction
        self._selectedTransactionId = selectedId
    }
    
    var body: some View {
        VStack {
            // Always show paid amount
            let paid = transaction.expenses.first!
            UserExpenseView(paid)
                .font(.headline)
            
            // Show other users expenses if selected
            if selectedTransactionId == transaction.id {
                let other = Array(transaction.expenses.dropFirst())
                ForEach(other, id: \.user.email) { expense in
                    UserExpenseView(expense)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .background(
            // Get tap gesture on transparent background
            Color.green.opacity(0.01)
                .onTapGesture {
                    withAnimation {
                        if selectedTransactionId == transaction.id {
                            selectedTransactionId = nil
                        } else {
                            selectedTransactionId = transaction.id
                        }
                    }
                }
        )
    }
}
