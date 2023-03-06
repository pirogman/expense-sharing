//
//  GroupDetailView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

/*
 Create group
 Add users
 Remove users
 ? Edit group title
 Share group to other devices
 
 */

class GroupDetailViewModel: ObservableObject {
    @Published private(set) var title: String
    @Published private(set) var users: [User]
    @Published private(set) var transactions: [ManagedTransaction]
    
    private let currencyFormatter: NumberFormatter = {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      return formatter
    }()
    
    init(_ group: ManagedGroup) {
        self.title = group.title
        self.users = group.users
        self.transactions = group.transactions
    }
}

struct GroupDetailChartView: View {
    var body: some View {
        HStack {
            Spacer()
            Circle()
                .foregroundColor(.red)
                .squareFrame(side: UIScreen.main.bounds.width * 0.6)
                .overlay(
                    Circle()
                        .foregroundColor(Color.init(uiColor: .systemBackground))
                        .padding(48)
                )
            Spacer()
        }
        .background(Color.init(uiColor: .systemBackground))
    }
}

struct GroupDetailUserView: View {
    let color: Color
    let user: User
    
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
        }
        .lineLimit(1)
    }
}

class CurrencyManager {
    static private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
      }()
    
    static func getText(for money: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: money)) ?? "NaN"
    }
}

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

struct GroupDetailView: View {
    @StateObject var vm: GroupDetailViewModel
    
    @State var selectedTransactionId: String?
    
    init(_ group: ManagedGroup) {
        self._vm = StateObject(wrappedValue: GroupDetailViewModel(group))
    }
    
    var body: some View {
        List {
            // Section with the pie chart
            Section {
                GroupDetailChartView()
            } header: {
                Text("Chart")
            }
            
            // Section with the list of users
            Section {
                ForEach(vm.users) { user in
                    GroupDetailUserView(color: .red, user: user)
                }
            } header: {
                Text("Users")
            }
            
            // Section with all transactions
            Section {
                ForEach(vm.transactions) { transaction in
                    GroupDetailTransactionView(transaction, selectedId: $selectedTransactionId)
                }
            } header: {
                Text("Transactions")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(vm.title)
    }
}
