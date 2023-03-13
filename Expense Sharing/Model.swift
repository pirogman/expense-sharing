//
//  Model.swift
//  Expense Sharing
//

import Foundation

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

struct ExportData: Codable {
    let users: [User]
    let groups: [Group]
}
