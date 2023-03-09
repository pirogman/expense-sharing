//
//  JSONManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import Foundation

class JSONManager {
    static let shared = JSONManager()
    private init() { }
    
    static func loadFrom(fileName name: String) -> ExportData {
        guard let jsonData = JSONManager.loadJSON(fileName: name),
              let exportData: ExportData = JSONManager.decodeJSON(from: jsonData)
        else {
            print("Failed to decode export data - return empty")
            return ExportData(users: [], groups: [])
        }
        return exportData
    }
    
    static func loadFrom(fileURL url: URL) -> ExportData {
        guard let jsonData = JSONManager.loadJSON(fileURL: url),
              let exportData: ExportData = JSONManager.decodeJSON(from: jsonData)
        else {
            print("Failed to decode export data - return empty")
            return ExportData(users: [], groups: [])
        }
        return exportData
    }
    
    static func saveToFile(_ exportData: ExportData, named: String) -> URL? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(exportData)
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(named).json")
            try data.write(to: url, options: .atomic)
            return url
        } catch let error {
            print("Encoding error: \(error)")
            return nil
        }
    }
    
    static func clearTempFile(named: String) {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(named).json")
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print("Removing file error: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    static private func decodeJSON<T: Decodable>(from data: Data) -> T? {
        do {
            let decoder = JSONDecoder()
            let jsonObject = try decoder.decode(T.self, from: data)
            return jsonObject
        } catch let error {
            print("Decoding error: \(error)")
            return nil
        }
    }
    
    static private func loadJSON(fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("No such file...")
            return nil
        }
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return jsonData
        } catch let error {
            print("Loading error: \(error)")
            return nil
        }
    }
    
    static private func loadJSON(fileURL: URL) -> Data? {
        guard fileURL.isFileURL else {
            print("No a file url...")
            return nil
        }
        do {
            let jsonData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return jsonData
        } catch let error {
            print("Loading error: \(error)")
            return nil
        }
    }
}

// MARK: - Data

extension String: Identifiable {
    public var id: String { self }
}

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
}

struct ExportData: Codable {
    let users: [User]
    let groups: [Group]
}

// MARK: - Managed Data

import Combine

struct ManagedUser: Identifiable {
    var id: String { email }
    
    let name: String
    let email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
    init(unknownUserEmail: String) {
        self.name = "[unknown]"
        self.email = unknownUserEmail
    }
}

typealias Expense = (user: ManagedUser, money: Double)

struct ManagedTransaction: Identifiable {
    let id: String
    let expenses: [Expense]
    let description: String?
}

struct ManagedGroup: Identifiable {
    let id: String
    let title: String
    let users: [ManagedUser]
    let transactions: [ManagedTransaction]
}

struct LocalData {
    let users: [ManagedUser]
    let groups: [ManagedGroup]
    
    init(_ exportData: ExportData) {
        let managedUsers = exportData.users.map { ManagedUser(name: $0.name, email: $0.email) }
        self.users = managedUsers
        self.groups = exportData.groups.map { group in
            // Get users in this group by email
            let groupUsers = group.users
                .map { email in
                    managedUsers.first(where: { $0.email == email }) ?? ManagedUser(unknownUserEmail: email)
                }
                .sorted(by: { $0.name < $1.name })
            
            // Manage transactions with users and sorting
            let groupTransactions: [ManagedTransaction] = group.transactions
                .map { transaction in
                    let expenses: [Expense] = transaction.expenses.keys
                        .map { key in
                            let user = groupUsers.first(where: { $0.email == key }) ?? ManagedUser(unknownUserEmail: key)
                            let money = transaction.expenses[key]!
                            return Expense(user, money)
                        }
                        .sorted(by: { abs($0.money) > abs($1.money) })
                    return ManagedTransaction(id: transaction.id, expenses: expenses, description: transaction.description)
                }
                .sorted { a, b in
                    guard let aMoney = a.expenses.first?.money else { return false }
                    guard let bMoney = a.expenses.first?.money else { return true }
                    return aMoney > bMoney
                }
            
            return ManagedGroup(id: group.id, title: group.title, users: groupUsers, transactions: groupTransactions)
        }
    }
}

class CurrencyManager {
    static private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
      }()
    
    static func getText(for money: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: money)) ?? "NaN"
    }
}
