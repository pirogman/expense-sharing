//
//  GroupAddTransactionViewModel.swift
//  Expense Sharing
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
    @Published private(set) var hint: String?
    
    @Published var paidAmount = 0.0
    @Published var otherUsersExpenses: [String: Double]
    @Published var description = ""
    
    var remainingExpenseAmount: Double {
        let totalExpenses = otherUsersExpenses.values.reduce(0.0, +)
        return paidAmount - totalExpenses
    }
    
    let groupId: String
    let groupTitle: String
    let currencyCode: String?
    let payingUserId: String
    let otherUsers: [FIRUser]
    
    init(groupId: String, groupTitle: String, currencyCode: String?, payingUserId: String, otherUsers: [FIRUser]) {
        self.groupId = groupId
        self.groupTitle = groupTitle
        self.currencyCode = currencyCode
        self.payingUserId = payingUserId
        self.otherUsers = otherUsers
        self.otherUsersExpenses = otherUsers.reduce(into: [String: Double]()) { dict, user in
            dict[user.id] = 0.0
        }
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
    
    func setExpense(_ amount: Double, on user: FIRUser) -> Result<Void, Error> {
        guard isValidAmount(amount) else {
            return .failure(TransactionError.invalidAmount)
        }
        guard amount <= remainingExpenseAmount else {
            return .failure(TransactionError.invalidExpenseAmount)
        }
        
        otherUsersExpenses[user.id] = amount
        return .success(())
    }
    
    func addTransaction(completion: @escaping VoidResultBlock) {
        guard isValidAmount(paidAmount) else {
            completion(.failure(TransactionError.invalidAmount))
            return
        }
        guard let validDescription = Validator.validateTransactionDescription(description) else {
            completion(.failure(ValidationError.invalidTransactionDescription))
            return
        }
        var expenses = [payingUserId: paidAmount]
        for key in otherUsersExpenses.keys {
            guard let amount = otherUsersExpenses[key], amount > 0 else { continue }
            expenses[key] = -amount
        }
        let newTransaction = FIRTransaction(groupId: groupId, id: UUID().uuidString, expenses: expenses, description: validDescription, image: nil)
        hint = "Adding transaction..."
        FIRManager.shared.groupAddTransaction(newTransaction, completion: completion)
    }
}
