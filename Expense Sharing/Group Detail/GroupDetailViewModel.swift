//
//  GroupDetailViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

/// Format: user email, user name, paid/owed amount, color for user in this group
typealias ExpenseWithInfo = (String, String, Double, Color)

/// Format: amount to transfer, user who paid, user who received
typealias UserCashFlowAction = (Double, User, User)

class GroupDetailViewModel: ObservableObject {
    @Published private(set) var groupTitle = ""
    @Published private(set) var groupUsers = [User]()
    @Published private(set) var groupTransactions = [Transaction]()
    @Published private(set) var groupCurrencyCode: String?
    @Published private(set) var userColors = [String: Color]()
    
    static private let colors: [Color] = [
        .red, .orange, .yellow, .purple, .indigo, .blue,
//        .pink, // Too similar to .red
//        .green, .cyan, .teal, // Bad on gradient background
//        .gray, // Not very pleasant looking
        .black, .white,
    ]
    private let groupColors = GroupDetailViewModel.colors.shuffled()
    
    let groupId: String
    let userEmail: String
    
    init(groupId: String, forUserEmail userEmail: String) {
        self.groupId = groupId
        self.userEmail = userEmail
        
        updateGroup()
    }
    
    init(group: Group, forUserEmail userEmail: String) {
        self.groupId = group.id
        self.userEmail = userEmail
        
        updateGroupValues(to: group)
    }
    
    private func updateGroupValues(to group: Group) {
        self.groupTitle = group.title
        self.groupUsers = DBManager.shared.getUsers(in: group).sorted { a, b in
            a.name > b.name
        }
        self.groupTransactions = group.transactions.sorted { a, b in
            let aPaid = a.expenses.values.max() ?? 0.0
            let bPaid = b.expenses.values.max() ?? 0.0
            return aPaid > bPaid
        }
        self.groupCurrencyCode = group.currencyCode
        
        resetUserColors(for: group.users)
    }
    
    private func resetUserColors(for emails: [String]) {
        userColors.removeAll()
        
        let colorsCount = groupColors.count
        let usersCount = emails.count
        for userIndex in 0..<usersCount {
            let colorIndex = userIndex % colorsCount
            userColors[emails[userIndex]] = groupColors[colorIndex]
        }
    }
    
    func updateGroup() {
        let group = DBManager.shared.getGroup(byId: groupId)!
        updateGroupValues(to: group)
    }
    
    func editTitle(_ title: String) -> Result<Void, Error> {
        guard let validTitle = Validator.validateGroupTitle(title) else {
            return .failure(ValidationError.invalidGroupTitle)
        }
        
        DBManager.shared.editGroup(byId: groupId, title: validTitle)
        self.groupTitle = validTitle
        return .success(())
    }
    
    func removeTransaction(_ transaction: Transaction) {
        let updatedTransactions = groupTransactions.filter { $0.id != transaction.id }
        DBManager.shared.editGroup(byId: groupId, transactions: updatedTransactions)
        groupTransactions = updatedTransactions
    }
    
    func getUserAmounts(for user: User) -> (Double, Double) {
        var totalPaid = 0.0
        var totalShare = 0.0
        for transaction in groupTransactions {
            let paidUserShare = transaction.expenses.values.reduce(0, +)
            if let amount = transaction.expenses[user.email] {
                if amount > 0 {
                    totalPaid += amount
                    totalShare += -paidUserShare
                } else {
                    totalShare += amount
                }
            }
        }
        return (totalPaid, totalShare)
    }
    
    func getUsersAmountsLimits() -> (Double, Double, Double) {
        var maxPaid = 0.0
        var minShare = 0.0
        for user in groupUsers {
            let amounts = getUserAmounts(for: user)
            if amounts.0 > maxPaid {
                maxPaid = amounts.0
            }
            if amounts.1 < minShare {
                minShare = amounts.1
            }
        }
        return (maxPaid, minShare, max(maxPaid, abs(minShare)))
    }
    
    func getTotalSpent() -> Double {
        groupUsers.map { getUserAmounts(for: $0).0 }.reduce(0, +)
    }
    
    func getTransactionExpenses(_ transaction: Transaction) -> [ExpenseWithInfo] {
        var result = [ExpenseWithInfo]()
        for key in transaction.expenses.keys {
            let name = groupUsers.first(where: { $0.email == key })?.name ?? key
            if let amount = transaction.expenses[key], amount != 0 {
                let color = userColors[key] ?? .white
                result.append((String(key), name, amount, color))
            }
        }
        result.sort { abs($0.2) > abs($1.2) }
        return result
    }
    
    func getCashFlowActions() -> [UserCashFlowAction] {
        let money: [Double] = groupUsers.map { user in
            let amounts = getUserAmounts(for: user)
            return amounts.1 + amounts.0
        }
        let actions = ExpenseCalculator.calculateCashFlow(in: money)
        return actions.map { ($0.0, groupUsers[$0.1], groupUsers[$0.2]) }
    }
    
    // MARK: - Share
    
    private var tempFileName: String?
    
    func getGroupShareActivities() -> [AnyObject] {
        let group = DBManager.shared.getGroup(byId: groupId)!
        tempFileName = groupTitle.replacingOccurrences(of: " ", with: "_")
        return ShareManager.exportGroup(group, includeUsers: true, fileName: tempFileName!)
    }
    
    func clearSharedGroupFile() {
        guard let name = tempFileName else { return }
        tempFileName = nil
        JSONManager.clearTempFile(named: name)
    }
}

/// Format: amount to transfer, index of who paid, index of who received
typealias CashFlowAction = (Double, Int, Int)

class ExpenseCalculator {
    static func calculateCashFlow(in array: [Double]) -> [CashFlowAction] {
        guard !array.isEmpty else { return [] }
        return calculateCashFlowRecursively(in: array, actions: []).1
    }
    
    static private func calculateCashFlowRecursively(in array: [Double], actions: [CashFlowAction]) -> ([Double], [CashFlowAction]) {
        var cashArray = array
        var cashActions = actions
        
        // Get paying and receiving items
        let maxDebitIndex = getMinValueIndex(in: array)
        let maxCreditIndex = getMaxValueIndex(in: array)
        let maxDebit = array[maxDebitIndex]
        let maxCredit = array[maxCreditIndex]
        
        guard maxDebit < 0 && maxCredit > 0 else {
            // Calculated to the end, return
            return (cashArray, cashActions)
        }
        
        // Transfer cash
        let cash = min(abs(maxDebit), maxCredit)
        cashArray[maxDebitIndex] += cash
        cashArray[maxCreditIndex] -= cash
        cashActions.append((cash, maxCreditIndex, maxDebitIndex))
        
        // Continue until finished
        return calculateCashFlowRecursively(in: cashArray, actions: cashActions)
    }
    
    static private func getMinValueIndex(in array: [Double]) -> Int {
        var index = 0
        for i in 0..<array.count {
            if array[i] < array[index] {
                index = i
            }
        }
        return index
    }
    
    static private func getMaxValueIndex(in array: [Double]) -> Int {
        var index = 0
        for i in 0..<array.count {
            if array[i] > array[index] {
                index = i
            }
        }
        return index
    }
}
