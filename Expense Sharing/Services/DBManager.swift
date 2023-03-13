//
//  DBManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 07.03.2023.
//

import SwiftUI
import FirebaseDatabase
import FirebaseDatabaseSwift

enum SyncError: Error, LocalizedError {
    case invalidServerData
    
    public var errorDescription: String? {
        switch self {
        case .invalidServerData: return "Failed to sync with server."
        }
    }
}

/*
 struct User: Codable, Identifiable {
     var id: String { email }
     
     let name: String
     let email: String
 }

 struct Transaction: Codable, Identifiable {
     let id: String
     let expenses: [String: Double] // [email:money] with positive for who paid
     let description: String?
 }

 struct Group: Codable, Identifiable {
     let id: String
     let title: String
     let users: [String] // emails of users
     let transactions: [Transaction]
     let currencyCode: String?
 }
 */

protocol FRDStorable {
    init?(dict: [String: Any])
    func toDictionary() -> [String: Any]
}

extension User: FRDStorable {
    init?(dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let email = dict["email"] as? String
        else { return nil }
        
        self.init(name: name, email: email)
    }
    
    func toDictionary() -> [String : Any] {
        ["name": name, "email": email]
    }
}

extension Transaction: FRDStorable {
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              var expenses = dict["expenses"] as? Dictionary<String, Double>
        else { return nil }
        let description = dict["description"] as? String
        
        let tupleArray: [(String, Double)] = expenses.map { (key: String, value: Double) in
            let safeKey = key.replacingOccurrences(of: "!", with: ".")
            return (safeKey, value)
        }
        expenses = Dictionary(uniqueKeysWithValues: tupleArray)
        
        self.init(id: id, expenses: expenses, description: description)
    }
    
    func toDictionary() -> [String : Any] {
        let tupleArray: [(String, Double)] = expenses.map { (key: String, value: Double) in
            let safeKey = key.replacingOccurrences(of: ".", with: "!")
            return (safeKey, value)
        }
        let safeExpenses = Dictionary(uniqueKeysWithValues: tupleArray)
        
        var dict: [String: Any] = [
            "id": id,
            "expenses": safeExpenses
        ]
        if let safeDescription = description {
            dict["description"] = safeDescription
        }
        return dict
    }
}

extension Group: FRDStorable {
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let users = dict["users"] as? [String],
              let transactions = dict["transactions"] as? [Dictionary<String, Any>]
        else { return nil }
        let currencyCode = dict["currencyCode"] as? String
        
        let safeTransactions = transactions.compactMap { value in
            Transaction(dict: value)
        }
        
        self.init(id: id, title: title, users: users, transactions: safeTransactions, currencyCode: currencyCode)
    }
    
    func toDictionary() -> [String : Any] {
        let safeExpenses = transactions.map { $0.toDictionary() }
        
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "users": users,
            "transactions": safeExpenses
        ]
        if let code = currencyCode {
            dict["currencyCode"] = code
        }
        return dict
    }
}

extension ExportData: FRDStorable {
    init?(dict: [String: Any]) {
        let users = (dict["users"] as? [Dictionary<String, Any>])?.compactMap { User(dict: $0) } ?? []
        let groups = (dict["groups"] as? [Dictionary<String, Any>])?.compactMap { Group(dict: $0) } ?? []
        self.init(users: users, groups: groups)
    }
    
    func toDictionary() -> [String : Any] {
        ["users": users.map { $0.toDictionary() },
         "groups": groups.map { $0.toDictionary() }]
    }
}

class FRDManager {
    static let shared = FRDManager()
    private init() {
        ref = Database.database().reference()
        
        groupRemoveListenerId = ref.child("groups").observe(.childRemoved) { snapshot in
            print("Server: got remove group \(snapshot)")
            if let dict = snapshot.value as? Dictionary<String, Any>,
               let group = Group(dict: dict) {
                DBManager.shared.removeGroup(byId: group.id)
            }
        }
    }
    
    deinit {
        ref.removeObserver(withHandle: groupRemoveListenerId)
    }
    
    private let ref: DatabaseReference!
    private let groupRemoveListenerId: UInt
    
    func syncToServer(users: [User], groups: [Group], completion: @escaping ([Error]) -> Void) {
        var usersToAdd = users.count
        var groupToAdd = groups.count
        var errors = [Error]()
        
        for user in users {
            addUser(user) { result in
                usersToAdd -= 1
                switch result {
                case .success: break
                case .failure(let error):
                    errors.append(error)
                }
                if groupToAdd == 0 && usersToAdd == 0 {
                    completion(errors)
                }
            }
        }
        for group in groups {
            addGroup(group) { result in
                groupToAdd -= 1
                switch result {
                case .success: break
                case .failure(let error):
                    errors.append(error)
                }
                if groupToAdd == 0 && usersToAdd == 0 {
                    completion(errors)
                }
            }
        }
    }
    
    func syncFromServer(completion: @escaping (Result<Void, Error>) -> Void) {
        ref.getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let dict = snapshot?.value as? Dictionary<String, Any>,
               let data = ExportData(dict: dict) {
                DBManager.shared.reset(with: data)
                completion(.success(()))
                return
            }
            
            completion(.failure(SyncError.invalidServerData))
        }
    }
    
    func getChildPathFromEmail(_ email: String) -> String {
        // Child path cannot contain symbols: '/' '.' '#' '$' '[' or ']'
        email.replacingOccurrences(of: ".", with: "!")
    }
    
    func addUser(_ user: User, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let emailToId = getChildPathFromEmail(user.email)
        ref.child("users").child(emailToId).setValue(user.toDictionary()) { error, _ in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    func addGroup(_ group: Group, completion: ((Result<Void, Error>) -> Void)? = nil) {
        ref.child("groups").child(group.id).setValue(group.toDictionary()) { error, _ in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(()))
            }
        }
    }
    
    func removeGroup(id: String) {
        ref.child("groups").child(id).removeValue()
    }
}

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

