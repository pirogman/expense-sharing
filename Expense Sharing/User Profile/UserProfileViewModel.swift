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
    }
    
    func updateGroups(search: String? = nil) {
        if search.hasText {
            groups = DBManager.shared.getGroups(for: user)
                .filter({ $0.title.lowercased().contains(search!.lowercased()) })
        } else {
            groups = DBManager.shared.getGroups(for: user)
        }
    }
    
    func editName(_ name: String) -> Result<Void, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(ValidationError.invalidName)
        }
        return .success(())
    }
    
    func deleteGroup(_ group: Group) {
        
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
        let shareFileName = user.name.replacingOccurrences(of: " ", with: "_")
        tempFileName = shareFileName
        return ShareManager.exportUser(user, fileName: shareFileName)
    }
    
    func clearSharedUserFile() {
        guard let name = tempFileName else { return }
        tempFileName = nil
        JSONManager.clearTempFile(named: name)
    }
}

class ShareManager {
    static func exportUser(_ user: User, fileName: String) -> [AnyObject] {
        let userGroups = DBManager.shared.getGroups(for: user)
        let exportData = ExportData(users: [user], groups: userGroups)
        return getShareActivities(exportData, fileName: fileName)
    }
    
    static func exportGroup(_ group: Group, fileName: String) -> [AnyObject] {
        let groupUsers = group.users.compactMap { email in
            DBManager.shared.getUser(by: email)
        }
        let exportData = ExportData(users: groupUsers, groups: [group])
        return getShareActivities(exportData, fileName: fileName)
    }
    
    static func getShareActivities(_ exportData: ExportData, fileName: String) -> [AnyObject] {
        var activities = [AnyObject]()
        if let url = JSONManager.saveToFile(exportData, named: fileName) {
            activities.append(url as AnyObject)
        }
        return activities
    }
}
