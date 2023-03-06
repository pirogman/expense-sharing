//
//  GroupDetailView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

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
                let moneyText = CurrencyManager.getText(for: vm.totalExpenses)
                GroupDetailChartView(centerText: moneyText)
            } header: {
                Text("Chart")
            }
            
            // Section with the list of users
            Section {
                ForEach(vm.users) { user in
                    GroupDetailUserView(color: .red, user: user, money: vm.getTotalExpensesForUser(by: user.id))
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
