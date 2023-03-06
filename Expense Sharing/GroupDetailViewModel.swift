//
//  GroupDetailViewModel.swift
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
    @Published private(set) var totalExpenses: Double
    
    init(_ group: ManagedGroup) {
        self.title = group.title
        self.users = group.users
        self.transactions = group.transactions
        self.totalExpenses = group.transactions
            .map { $0.expenses.first?.money ?? 0.0 }
            .reduce(0, +)
    }
    
    func getTotalExpensesForUser(by userId: String) -> Double {
        var total = 0.0
        for transaction in transactions {
            if let paid = transaction.expenses.first, paid.user.id == userId {
                total += paid.money
            }
        }
        return total
    }
}
