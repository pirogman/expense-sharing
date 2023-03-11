//
//  UserProfileViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published private(set) var name: String
    @Published private(set) var userGroups = [Group]()
    
    var user: User { User(name: name, email: email) }
    
    let email: String
    
    init(_ user: User) {
        self.email = user.email
        self.name = user.name
    }
    
    func updateUserGroups(search: String? = nil) {
        userGroups = DBManager.shared.getGroups(for: email, search: search)
    }
    
    func editName(_ name: String) -> Result<Void, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(ValidationError.invalidUserName)
        }
        
        DBManager.shared.editUser(by: email, name: validName)
        self.name = validName
        return .success(())
    }
    
    func deleteGroup(_ group: Group) {
        DBManager.shared.removeGroup(byId: group.id)
        userGroups.removeAll(where: { $0.id == group.id })
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
    
    // MARK: - Share
    
    private var tempFileName: String?
    
    func getUserShareActivities() -> [AnyObject] {
        tempFileName = name.replacingOccurrences(of: " ", with: "_")
        return ShareManager.exportUser(user, includeGroups: true, fileName: tempFileName!)
    }
    
    func clearSharedUserFile() {
        guard let name = tempFileName else { return }
        tempFileName = nil
        JSONManager.clearTempFile(named: name)
    }
}
