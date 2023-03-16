//
//  AuthViewModel.swift
//  Expense Sharing
//

import SwiftUI
import UniformTypeIdentifiers

enum AuthError: Error, LocalizedError {
    case alreadyRegistered, notRegistered
    
    public var errorDescription: String? {
        switch self {
        case .alreadyRegistered: return "This user is already registered. Please, login instead."
        case .notRegistered: return "This user is not registered yet. Please, register instead."
        }
    }
}

enum ServerResetError: Error, LocalizedError {
    case invalidFile
    
    public var errorDescription: String? {
        switch self {
        case .invalidFile: return "Selected file has invalid JSON."
        }
    }
}

class AuthViewModel: ObservableObject {
    @Published var hint: String?
    
    // MARK: - Authorization
    
    func registerUser(name: String, email: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let validName = Validator.validateUserName(name) else {
            completion(.failure(ValidationError.invalidUserName))
            return
        }
        guard let validEmail = Validator.validateUserEmail(email) else {
            completion(.failure(ValidationError.invalidUserEmail))
            return
        }
        // Check if already there and add new user
        hint = "Checking user..."
        let emailToId = validEmail.replacingOccurrences(of: ".", with: "!")
        FIRManager.shared.getUser(id: emailToId) { [weak self] result in
            switch result {
            case .success(let user):
                if user != nil {
                    completion(.failure(AuthError.alreadyRegistered))
                } else {
                    self?.hint = "Creating user..."
                    let user = FIRUser(id: emailToId, name: validName, email: validEmail, groups: [])
                    FIRManager.shared.setUser(user) { userResult in
                        switch userResult {
                        case .success:
                            completion(.success(user.id))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginUser(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let validEmail = Validator.validateUserEmail(email) else {
            completion(.failure(ValidationError.invalidUserEmail))
            return
        }
        hint = "Checking user..."
        let emailToId = validEmail.replacingOccurrences(of: ".", with: "!")
        FIRManager.shared.getUser(id: emailToId) { result in
            switch result {
            case .success(let user):
                if let user = user {
                    completion(.success(user.id))
                } else {
                    completion(.failure(AuthError.notRegistered))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Import
    
    let allowedContentTypes = [UTType.json]
    let allowsMultipleSelection = false
    
    func handleSelectingFile(_ result: Result<[URL], Error>) -> Result<ExportData, Error> {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    let data = JSONManager.loadFrom(fileURL: url)
                    return .success(data)
                }
            }
            return .failure(URLError.cannotOpenFile as! Error)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Server Reset
    
    func resetServer(with data: ExportData, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !data.users.isEmpty && !data.groups.isEmpty else {
            completion(.failure(ServerResetError.invalidFile))
            return
        }
        
        hint = "Handling users, groups and transactions from provided file..."
        
        var users = [FIRUser]()
        var groups = [FIRGroup]()
        var transactions = [FIRTransaction]()
        
        // Create user id for each email
        let emailToIdTuples: [(String, String)] = data.users.map { user in
            let idFromEmail = user.email.replacingOccurrences(of: ".", with: "!")
            return (user.email, idFromEmail)
        }
        let emailToIdDict = Dictionary(uniqueKeysWithValues: emailToIdTuples)
        
        for group in data.groups {
            let groupTransactions: [FIRTransaction] = group.transactions.map { transaction in
                let expensesTuples = transaction.expenses.map { (key, value) in
                    (emailToIdDict[key]!, value)
                }
                let expensesDict = Dictionary(uniqueKeysWithValues: expensesTuples)
                return FIRTransaction(
                    groupId: group.id,
                    id: transaction.id,
                    expenses: expensesDict,
                    description: nil,
                    image: nil
                )
            }
            let groupUsers = group.users.map { emailToIdDict[$0]! }
            let newGroup = FIRGroup(
                id: group.id,
                title: group.title,
                users: groupUsers,
                transactions: group.transactions.map { $0.id },
                currencyCode: nil
            )
            groups.append(newGroup)
            transactions += groupTransactions
        }
        
        for user in data.users {
            let id = emailToIdDict[user.email]!
            let userGroups = groups.filter { $0.users.contains(id) }
            let newUser = FIRUser(
                id: id,
                name: user.name,
                email: user.name,
                groups: userGroups.map { $0.id }
            )
            users.append(newUser)
        }
        
        guard !users.isEmpty && !groups.isEmpty && !transactions.isEmpty else {
            completion(.failure(ServerResetError.invalidFile))
            return
        }
        
        hint = "Clearing old server data..."
        
        FIRManager.shared.clearServerData { [weak self] clearResult in
            switch clearResult {
            case .success:
                self?.hint = "Server data cleared.\nUploading users..."
                FIRManager.shared.updateServer(users: users) { [weak self] usersResult in
                    switch usersResult {
                    case .success(let u):
                        self?.hint = "Uploaded \(u) users.\nUploading groups..."
                        FIRManager.shared.updateServer(groups: groups) { [weak self] groupsResult in
                            switch groupsResult {
                            case .success(let g):
                                self?.hint = "Uploaded \(u) users.\nUploaded \(g) groups.\nUploading transactions..."
                                FIRManager.shared.updateServer(transactions: transactions) { [weak self] transactionsResult in
                                    switch transactionsResult {
                                    case .success(let t):
                                        self?.hint = "Uploaded \(u) users.\nUploaded \(g) groups.\nUploaded \(t) transactions."
                                        completion(.success(()))
                                    case .failure(let error):
                                        print("upload transactions error: \(error)")
                                        completion(.failure(error))
                                    }
                                }
                            case .failure(let error):
                                print("upload groups error: \(error)")
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        print("update users error: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("clear server data error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func resetServerWithTestData(completion: @escaping (Result<Void, Error>) -> Void) {
        let testData = JSONManager.loadFrom(fileName: "TestData")
        resetServer(with: testData, completion: completion)
    }
}
