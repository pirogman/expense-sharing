//
//  UserProfileViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

class UserProfileViewModel: ObservableObject {
    let user: User
    
    @Published var groups = [Group]()
    
    init(user: User) {
        self.user = user
        
        groups = DBManager.shared.getGroups(for: user)
    }
    
    func getManagedGroup(from group: Group) -> ManagedGroup {
        let users: [ManagedUser] = group.users.map { email in
            if let user = DBManager.shared.getUser(by: email) {
                return ManagedUser(name: user.name, email: user.email)
            }
            return ManagedUser(unknownUserEmail: email)
        }
        let transactions: [ManagedTransaction] = group.transactions.map { transaction in
            let expenses: [Expense] = transaction.expenses.keys
                .map { key in
                    let user = users.first(where: { $0.email == key }) ?? ManagedUser(unknownUserEmail: key)
                    let money = transaction.expenses[key]!
                    return Expense(user, money)
                }
                .sorted(by: { abs($0.money) > abs($1.money) })
            return ManagedTransaction(id: transaction.id, expenses: expenses, description: transaction.description)
        }
        return ManagedGroup(id: group.id, title: group.title, users: users, transactions: transactions)
    }
}
