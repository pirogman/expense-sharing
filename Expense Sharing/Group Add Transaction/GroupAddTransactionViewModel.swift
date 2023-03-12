//
//  GroupAddTransactionViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI

enum TransactionError: Error, LocalizedError {
    case invalidAmount, invalidExpenseAmount
    
    public var errorDescription: String? {
        switch self {
        case .invalidAmount: return "Invalid amount. Please, provide a valid amount of money."
        case .invalidExpenseAmount: return "Invalid amount. Please, provide smaller amount of money."
        }
    }
}

class GroupAddTransactionViewModel: ObservableObject {
    @Published var paidAmount = 0.0
    @Published var otherUsersExpenses: [String: Double]
    @Published var description = ""
    
    var remainingExpenseAmount: Double {
        let totalExpenses = otherUsersExpenses.values.reduce(0.0, +)
        return paidAmount - totalExpenses
    }
    
    let groupId: String
    let payingUserEmail: String
    let otherUsers: [User]
    let transactions: [Transaction]
    let currencyCode: String?
    let groupTitle: String
    
    init(groupId: String, payingUserEmail: String) {
        self.groupId = groupId
        self.payingUserEmail = payingUserEmail
        
        let group = DBManager.shared.getGroup(byId: groupId)!
        let members = DBManager.shared.getUsers(in: group, excludeEmails: [payingUserEmail])
        self.otherUsers = members
        self.otherUsersExpenses = members.reduce(into: [String: Double]()) { dict, user in
            dict[user.email] = 0.0
        }
        self.transactions = group.transactions
        self.currencyCode = group.currencyCode
        self.groupTitle = group.title
    }
    
    init(group: Group, payingUserEmail: String) {
        self.groupId = group.id
        self.payingUserEmail = payingUserEmail
        
        let members = DBManager.shared.getUsers(in: group, excludeEmails: [payingUserEmail])
        self.otherUsers = members
        self.otherUsersExpenses = members.reduce(into: [String: Double]()) { dict, user in
            dict[user.email] = 0.0
        }
        self.transactions = group.transactions
        self.currencyCode = group.currencyCode
        self.groupTitle = group.title
    }
    
    func isValidAmount(_ number: Double) -> Bool {
        number >= 0.01
    }
    
    func splitEvenly() {
        let split = paidAmount / Double(otherUsers.count + 1)
        let validSplit = isValidAmount(split) ? split : 0.0
        for key in otherUsersExpenses.keys {
            otherUsersExpenses[key] = validSplit
        }
    }
    
    func resetSplit() {
        for key in otherUsersExpenses.keys {
            otherUsersExpenses[key] = 0.0
        }
    }
    
    func setExpense(_ amount: Double, on user: User) -> Result<Void, Error> {
        guard isValidAmount(amount) else {
            return .failure(TransactionError.invalidAmount)
        }
        guard amount <= remainingExpenseAmount else {
            return .failure(TransactionError.invalidExpenseAmount)
        }
        
        otherUsersExpenses[user.email] = amount
        return .success(())
    }
    
    func addTransaction() -> Result<Void, Error> {
        guard isValidAmount(paidAmount) else {
            return .failure(TransactionError.invalidAmount)
        }
        guard let validDescription = Validator.validateTransactionDescription(description) else {
            return .failure(ValidationError.invalidTransactionDescription)
        }
        
        var expenses = [payingUserEmail: paidAmount]
        for email in otherUsersExpenses.keys {
            guard let amount = otherUsersExpenses[email], amount > 0 else { continue }
            expenses[email] = -amount
        }
        
        let transaction = Transaction(id: UUID().uuidString,
                                      expenses: expenses,
                                      description: validDescription)
        let transactions = self.transactions + [transaction]
        
        DBManager.shared.editGroup(byId: groupId, transactions: transactions)
        return .success(())
    }
}
