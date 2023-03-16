//
//  FIRManager.swift
//  Expense Sharing
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

typealias VoidResultBlock = (Result<Void, Error>) -> Void

class FIRManager {
    static let shared = FIRManager()
    private init() {
        // Enable persistence to work offline
        Database.database().isPersistenceEnabled = true
        
        let ref = Database.database().reference()
        usersRef = ref.child("users")
        groupsRef = ref.child("groups")
        transactionsRef = ref.child("transactions")
    }
    
    private let usersRef: DatabaseReference!
    private let groupsRef: DatabaseReference!
    private let transactionsRef: DatabaseReference!
    
    func leaveGroup(userId: String, groupId: String, completion: @escaping VoidResultBlock) {
        editGroup(removeUserId: userId, groupId: groupId) { [unowned self] result in
            switch result {
            case .success:
                editUser(removeGroupId: groupId, userId: userId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - User
    
    func setUser(_ user: FIRUser, completion: @escaping VoidResultBlock) {
        usersRef.child(user.id).setValue(user.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editUser(name: String, userId: String, completion: @escaping VoidResultBlock) {
        usersRef.child(userId).updateChildValues(["name": name]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editUser(addGroupId: String, userId: String, completion: @escaping VoidResultBlock) {
        usersRef.child(userId).child("groups").updateChildValues([addGroupId: true]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editUser(removeGroupId: String, userId: String, completion: @escaping VoidResultBlock) {
        usersRef.child(userId).child("groups").child(removeGroupId).removeValue() { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func getUser(id: String, completion: @escaping (Result<FIRUser?, Error>) -> Void) {
        usersRef.child(id).getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            let user = FIRUser(snapshot: snapshot)
            completion(.success(user))
        }
    }
    
    func getUsersFor(groupId: String, completion: @escaping (Result<[FIRUser], Error>) -> Void) {
        let query = usersRef.queryOrdered(byChild: "groups/\(groupId)").queryEqual(toValue: true)
        query.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.success([]))
                return
            }
            let users = children.compactMap { FIRUser(snapshot: $0) }
            completion(.success(users))
        }
    }
    
    // MARK: - Group
    
    func setGroup(_ group: FIRGroup, completion: @escaping VoidResultBlock) {
        groupsRef.child(group.id).setValue(group.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editGroup(title: String, groupId: String, completion: @escaping VoidResultBlock) {
        groupsRef.child(groupId).updateChildValues(["title": title]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editGroup(addUserId: String, groupId: String, completion: @escaping VoidResultBlock) {
        groupsRef.child(groupId).child("users").updateChildValues([addUserId: true]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editGroup(removeUserId: String, groupId: String, completion: @escaping VoidResultBlock) {
        groupsRef.child(groupId).child("users").child(removeUserId).removeValue() { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editGroup(addTransactionId: String, groupId: String, completion: @escaping VoidResultBlock) {
        groupsRef.child(groupId).child("transactions").updateChildValues([addTransactionId: true]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func editGroup(removeTransactionId: String, groupId: String, completion: @escaping VoidResultBlock) {
        groupsRef.child(groupId).child("transactions").child(removeTransactionId).removeValue() { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func getGroup(id: String, completion: @escaping (Result<FIRGroup?, Error>) -> Void) {
        groupsRef.child(id).getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            let group = FIRGroup(snapshot: snapshot)
            completion(.success(group))
        }
    }
    
    func getGroupsFor(userId: String, completion: @escaping (Result<[FIRGroup], Error>) -> Void) {
        let query = groupsRef.queryOrdered(byChild: "users/\(userId)").queryEqual(toValue: true)
        query.observeSingleEvent(of: .value) { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                completion(.success([]))
                return
            }
            let groups = children.compactMap { FIRGroup(snapshot: $0) }
            completion(.success(groups))
        }
    }
    
    // MARK: - Transaction
    
    func setTransaction(_ transaction: FIRTransaction, completion: @escaping VoidResultBlock) {
        let ref = transactionsRef.child(transaction.groupId).child(transaction.id)
        ref.setValue(transaction.toDictionary()) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    func getTransaction(id: String, groupId: String, completion: @escaping (Result<FIRTransaction?, Error>) -> Void) {
        transactionsRef.child(groupId).child(id).getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            let transaction = FIRTransaction(groupId: groupId, snapshot: snapshot)
            completion(.success(transaction))
        }
    }
    
    func getTransactionsFor(groupId: String,  completion: @escaping (Result<[FIRTransaction], Error>) -> Void) {
        transactionsRef.child(groupId).getData { error, snapshot in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let children = snapshot?.children.allObjects as? [DataSnapshot] else {
                completion(.success([]))
                return
            }
            let transactions = children.compactMap { FIRTransaction(groupId: groupId, snapshot: $0) }
            completion(.success(transactions))
        }
    }
    
    // MARK: - Server Reset
    
    /// `Cation!` Clears all branches
    func clearServerData(completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = Database.database().reference()
        ref.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    /// Updates `users` with given values
    func updateServer(users: [FIRUser], completion: @escaping (Result<Int, Error>) -> Void) {
        let tuples: [(String, [String: Any])] = users.map { user in
            let key = user.id
            let value = user.toDictionary()
            return (key, value)
        }
        let dict = Dictionary(uniqueKeysWithValues: tuples)
        usersRef.updateChildValues(dict) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(users.count))
        }
    }
    
    /// Updates `groups` branch with given values
    func updateServer(groups: [FIRGroup], completion: @escaping (Result<Int, Error>) -> Void) {
        let tuples: [(String, [String: Any])] = groups.map { group in
            let key = group.id
            let value = group.toDictionary()
            return (key, value)
        }
        let dict = Dictionary(uniqueKeysWithValues: tuples)
        groupsRef.updateChildValues(dict) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(groups.count))
        }
    }
    
    /// Updates `transactions` branch with given values
    func updateServer(transactions: [FIRTransaction], completion: @escaping (Result<Int, Error>) -> Void) {
        // Store transactions nested under groupId
        var dict = [String: [String: [String: Any]]]()
        for t in transactions {
            if var old = dict[t.groupId] {
                old[t.id] = t.toDictionary()
                dict[t.groupId] = old
            } else {
                dict[t.groupId] = [t.id: t.toDictionary()]
            }
        }
        transactionsRef.updateChildValues(dict) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(transactions.count))
        }
    }
}

// MARK: - Model to/from DataSnapshot

extension Array where Element == String {
    /// Maps array into dictionary. Takes values as keys and puts provided value for each key
    func toDictionary<Value: Any>(with value: Value) -> Dictionary<Element, Value> {
        Dictionary(uniqueKeysWithValues: self.map({ ($0, value) }))
    }
}

extension Dictionary where Key == String {
    /// Maps dictionary into array. Takes all keys and ignores values
    func toArray() -> Array<Key> {
        keys.map({ String($0) })
    }
}

extension FIRUser {
    init?(snapshot: DataSnapshot?) {
        guard let id = snapshot?.key,
              let dict = snapshot?.value as? [String: Any],
              let name = dict["name"] as? String,
              let email = dict["email"] as? String
        else { return nil }
        let groups = (dict["groups"] as? [String: Any] ?? [:]).toArray()
        self.init(id: id, name: name, email: email, groups: groups)
    }
    
    func toDictionary() -> [String : Any] {
        var dict: [String: Any] = [
            "name": name,
            "email": email,
        ]
        if !groups.isEmpty {
            dict["groups"] = groups.toDictionary(with: true)
        }
        return dict
    }
}

extension FIRTransaction {
    init?(groupId: String, snapshot: DataSnapshot?) {
        guard let id = snapshot?.key,
              let dict = snapshot?.value as? [String: Any],
              let expenses = dict["expenses"] as? [String: Double]
        else { return nil }
        let description = dict["description"] as? String
        let image = dict["image"] as? String
        self.init(groupId: groupId, id: id, expenses: expenses, description: description, image: image)
    }
    
    func toDictionary() -> [String : Any] {
        // Do not embed groupId as transactions are nested under it anyway
        var dict: [String: Any] = [
            "expenses": expenses
        ]
        if let description = description {
            dict["description"] = description
        }
        if let image = image {
            dict["image"] = image
        }
        return dict
    }
}

extension FIRGroup {
    init?(snapshot: DataSnapshot?) {
        guard let id = snapshot?.key,
              let dict = snapshot?.value as? [String: Any],
              let title = dict["title"] as? String
        else { return nil }
        let currencyCode = dict["currencyCode"] as? String
        let users = (dict["users"] as? [String: Any] ?? [:]).toArray()
        let transactions = (dict["transactions"] as? [String: Any] ?? [:]).toArray()
        self.init(id: id, title: title, users: users, transactions: transactions, currencyCode: currencyCode)
    }
    
    func toDictionary() -> [String : Any] {
        var dict: [String: Any] = [
            "title": title,
        ]
        if let currencyCode = currencyCode {
            dict["currencyCode"] = currencyCode
        }
        if !users.isEmpty {
            dict["users"] = users.toDictionary(with: true)
        }
        if !transactions.isEmpty {
            dict["transactions"] = transactions.toDictionary(with: true)
        }
        return dict
    }
}
