//
//  DBManager.swift
//  Expense Sharing
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

class DBManager {
    static let shared = DBManager()
    private init() { }
    
    private(set) var users = [User]()
    private(set) var groups = [Group]()
    
    // MARK: - Users
    
    func getUser(by email: String) -> User? {
        users.first(where: { $0.email == email })
    }
    
    func getUsers(in group: Group, excludeEmails: [String] = []) -> [User] {
        guard !group.users.isEmpty else { return [] }
        
        let foundMembers = users.filter { group.users.contains($0.email) }
        if !excludeEmails.isEmpty {
            return foundMembers.filter { !excludeEmails.contains($0.email) }
        } else {
            return foundMembers
        }
    }
    
    func getUsers(excludeEmails: [String] = [], search: String? = nil) -> [User] {
        // Do not filter if search not provided
        guard let searchText = search?.lowercased(), !searchText.isEmpty else {
            if !excludeEmails.isEmpty {
                return users.filter { !excludeEmails.contains($0.email) }
            } else {
                return users
            }
        }
        
        let foundByName = users.filter { user in
            guard !excludeEmails.contains(user.email) else { return false }
            return user.name.lowercased().contains(searchText)
        }
        let foundByEmail = users.filter { user in
            guard foundByName.contains(where: { $0.id != user.id }) else { return false }
            return user.email.lowercased().contains(searchText)
        }
        return foundByName + foundByEmail
    }
    
    /// Adds new user to the DB if not already there, otherwise return `nil`
    func addUser(name: String, email: String) -> User? {
        guard getUser(by: email) == nil else {
            return nil
        }
        let newUser = User(name: name, email: email)
        users.append(newUser)
        FRDManager.shared.addUser(newUser)
        return newUser
    }
    
    func editUser(by email: String, name: String? = nil) {
        guard let index = users.firstIndex(where: { $0.email == email }) else { return }
        let updateUser = User(name: name ?? users[index].name, email: email)
        FRDManager.shared.addUser(updateUser)
        users[index] = updateUser
    }
    
    // MARK: - Groups
    
    func getGroup(byId id: String) -> Group? {
        groups.first(where: { $0.id == id })
    }
    
    func getGroups(for userEmail: String, search: String? = nil) -> [Group] {
        guard let searchText = search?.lowercased(), !searchText.isEmpty else {
            return groups.filter { $0.users.contains(userEmail) }
        }
        
        let foundByTitle = groups.filter { group in
            return group.title.lowercased().contains(searchText)
        }
        return foundByTitle
    }
    
    func addNewGroup(title: String, userEmails: [String], currencyCode: String? = nil) {
        let newGroup = Group(id: UUID().uuidString,
                             title: title,
                             users: userEmails,
                             transactions: [],
                             currencyCode: currencyCode)
        FRDManager.shared.addGroup(newGroup)
        groups.append(newGroup)
    }
    
    func editGroup(byId id: String, title: String? = nil, users: [String]? = nil, transactions: [Transaction]? = nil) {
        guard let index = groups.firstIndex(where: { $0.id == id }) else { return }
        let updateGroup = Group(id: groups[index].id,
                                title: title ?? groups[index].title,
                                users: users ?? groups[index].users,
                                transactions: transactions ?? groups[index].transactions,
                                currencyCode: groups[index].currencyCode)
        FRDManager.shared.addGroup(updateGroup)
        groups[index] = updateGroup
    }
    
    func removeGroup(byId id: String) {
        groups.removeAll(where: { $0.id == id })
        FRDManager.shared.removeGroup(id: id)
    }
    
    // MARK: - Import
    
    func reset(with exportData: ExportData) {
        users = exportData.users
        groups = exportData.groups
    }
    
    func importData(_ exportData: ExportData, prioritiseImported: Bool = true) {
        for newUser in exportData.users {
            // Treat new user as more relevant that local one and update if needed
            if let index = users.firstIndex(where: { $0.id == newUser.id }) {
                if prioritiseImported {
                    users[index] = newUser
                }
            } else {
                users.append(newUser)
            }
        }
        
        for newGroup in exportData.groups {
            // Treat new group as more relevant that local one and update if needed
            if let index = groups.firstIndex(where: { $0.id == newGroup.id }) {
                if prioritiseImported {
                    groups[index] = newGroup
                }
            } else {
                groups.append(newGroup)
            }
        }
    }
    
    // MARK: - Testing
    
    func loadTestData() {
        let testData = JSONManager.loadFrom(fileName: "TestData")
        importData(testData)
    }
}

