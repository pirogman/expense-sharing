//
//  GroupDetailViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

/*
 Create group
 Edit group title
 Add/remove users
 Add/remove transactions
 Share group to other devices
 */

class GroupDetailViewModel: ObservableObject {
    @Published private(set) var title: String
    @Published private(set) var users: [ManagedUser]
    @Published private(set) var transactions: [ManagedTransaction]
    @Published private(set) var totalExpenses: Double
    
    private let group: ManagedGroup
    
    init(_ group: ManagedGroup) {
        self.group = group
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
    
    func calculateTotalExpenses() {
        totalExpenses = transactions
            .map { $0.expenses.first?.money ?? 0.0 }
            .reduce(0, +)
    }
    
    func updateTitle(_ newTitle: String) {
        guard !newTitle.isEmpty else {
            // Can not set an empty title for the group
            return
        }
        guard title != newTitle else {
            // Title have not changed
            return
        }
        title = newTitle
    }
    
    func deleteUsers(at indexSet: IndexSet) {
        guard indexSet.count < users.count else {
            // Can not delete all users from the group
            return
        }
        users.remove(atOffsets: indexSet)
    }
    
    func deleteTransactions(at indexSet: IndexSet) {
        // Can remove all transactions from the group
        transactions.remove(atOffsets: indexSet)
        calculateTotalExpenses()
    }
    
    func getGroupShareActivities() -> [AnyObject] {
        // Convert managed group to export data
        let exportTransactions: [Transaction] = self.transactions.map { transaction in
            let exportExpenses = transaction.expenses.reduce(into: [String: Double]()) { dict, expense in
                dict[expense.user.email] = expense.money
            }
            return Transaction(id: transaction.id, expenses: exportExpenses, description: transaction.description)
        }
        let exportGroup = Group(id: self.group.id, title: self.title, users: self.users.map({ $0.email }), transactions: exportTransactions)
        let exportUsers = self.users.map { User(name: $0.name, email: $0.email) }
        let exportData = ExportData(users: exportUsers, groups: [exportGroup])
        
        // Share as a single JSON file
        var activities = [AnyObject]()
        if let url = JSONManager.saveToFile(exportData) {
            activities.append(url as AnyObject)
        }
        return activities
    }
}
