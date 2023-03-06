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
    
    static func loadTestData() -> LocalData {
        let data = loadJSON(fileName: "TestData")!
        let exportedData: ExportData = decodeJSON(from: data)!
        return LocalData(exportedData)
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

struct GroupWithUsers: Identifiable {
    let id: String
    let title: String
    let users: [User]
    let transactions: [Transaction]
}

struct LocalData {
    let users: [User]
    let groups: [GroupWithUsers]
    
    init(_ exportData: ExportData) {
        self.users = exportData.users
        self.groups = exportData.groups.map { group in
            let groupUsers = group.users.map { email in
                exportData.users.first(where: { $0.email == email }) ?? User(name: "[unknown]", email: email)
            }
            return GroupWithUsers(id: group.id, title: group.title, users: groupUsers, transactions: group.transactions)
        }
    }
}
