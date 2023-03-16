//
//  GroupDetailViewModel.swift
//  Expense Sharing
//

import SwiftUI
import FirebaseDatabase
import FirebaseDatabaseSwift

/// Format: user email, user name, paid/owed amount, color for user in this group
typealias ExpenseWithInfo = (String, String, Double, Color)

/// Format: amount to transfer, user who paid, user who received
typealias UserCashFlowAction = (Double, FIRUser, FIRUser)

class GroupDetailViewModel: ObservableObject {
    @Published private(set) var hint: String?
    
    @Published private(set) var groupTitle = ""
    @Published private(set) var groupUsers = [FIRUser]()
    @Published private(set) var groupTransactions = [FIRTransaction]()
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
    let userId: String
    
    private var groupRef: DatabaseReference!
    private var observeGroupHandler: UInt!
    
    init(groupId: String, forUserId userId: String) {
        self.groupId = groupId
        self.userId = userId
        
        groupRef = Database.database().reference().child("groups").child(groupId)
        observeGroupHandler = groupRef.observe(.value) { [weak self] snapshot in
            guard let group = FIRGroup(snapshot: snapshot) else { return }
            self?.update(on: group)
        }
    }
    
    deinit {
        groupRef.removeObserver(withHandle: observeGroupHandler)
    }
    
    private func update(on group: FIRGroup) {
        groupTitle = group.title
        groupCurrencyCode = group.currencyCode
        let oldCount = groupUsers.count
        FIRManager.shared.getUsersFor(groupId: groupId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let groupUsers):
                self.groupUsers = groupUsers
                if oldCount != groupUsers.count {
                    self.resetUserColors(for: group.users)
                }
            case .failure(let error):
                print("failed to get users for group with error: \(error)")
                break
            }
        }
        FIRManager.shared.getTransactionsFor(groupId: groupId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let groupTransactions):
                self.groupTransactions = groupTransactions
            case .failure(let error):
                print("failed to get transactions for group with error: \(error)")
                break
            }
        }
    }
    
    private func resetUserColors(for ids: [String]) {
        userColors.removeAll()
        
        let colorsCount = groupColors.count
        let usersCount = ids.count
        for userIndex in 0..<usersCount {
            let colorIndex = userIndex % colorsCount
            userColors[ids[userIndex]] = groupColors[colorIndex]
        }
    }
    
    func editTitle(_ title: String, completion: @escaping VoidResultBlock) {
        guard let validTitle = Validator.validateGroupTitle(title) else {
            completion(.failure(ValidationError.invalidGroupTitle))
            return
        }
        hint = "Editing group title..."
        FIRManager.shared.editGroup(title: validTitle, groupId: groupId, completion: completion)
    }
    
    func removeTransaction(_ transaction: FIRTransaction, completion: @escaping VoidResultBlock) {
        hint = "Deleting transaction..."
        FIRManager.shared.groupDeleteTransaction(transaction, completion: completion)
    }
    
    /// Tuple format:
    /// - 0: total paid amount by given user (positive)
    /// - 1: total share amount by given user (negative)
    func getUserAmounts(for user: FIRUser) -> (Double, Double) {
        var totalPaid = 0.0
        var totalShare = -0.0
        for transaction in groupTransactions {
            let paidUserShare = transaction.expenses.values.reduce(0, +)
            if let amount = transaction.expenses[user.id] {
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
    
    /// Tuple format:
    /// - 0: maximum paid amount by any user (positive)
    /// - 1: maximum share amount by any user (negative)
    /// - 2: maximum value from paid and share amounts (positive)
    func getUsersAmountsLimits() -> (Double, Double, Double) {
        var maxPaid = 0.0
        var minShare = -0.0
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
    
    func getTransactionExpenses(_ transaction: FIRTransaction) -> [ExpenseWithInfo] {
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
            return -(amounts.0 - abs(amounts.1))
        }
        let actions = ExpenseCalculator.calculateCashFlow(in: money)
        return actions.map { ($0.0, groupUsers[$0.1], groupUsers[$0.2]) }
    }
}
