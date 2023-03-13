//
//  FRDManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 13.03.2023.
//

import Foundation
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
            
            if let topChildren = snapshot?.children.allObjects as? [DataSnapshot] {
                var users = [User]()
                var groups = [Group]()
                
                if let usersSnapshots = topChildren.first(where: { $0.key == "users" })?.children.allObjects as? [DataSnapshot] {
                    let dicts = usersSnapshots.compactMap { $0.value as? [String: Any] }
                    users = dicts.compactMap { User(dict: $0) }
                }
                if let groupsSnapshots = topChildren.first(where: { $0.key == "groups" })?.children.allObjects as? [DataSnapshot] {
                    let dicts = groupsSnapshots.compactMap { $0.value as? [String: Any] }
                    groups = dicts.compactMap { Group(dict: $0) }
                }
                
                let data = ExportData(users: users, groups: groups)
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

// MARK: - Model to FRDStorable

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
