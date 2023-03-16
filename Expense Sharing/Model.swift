//
//  Model.swift
//  Expense Sharing
//

import Foundation

struct FIRUser: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let groups: [String]
}

struct FIRTransaction: Codable, Identifiable {
    let groupId: String // transactions are nested under groupId
    let id: String
    let expenses: [String: Double] // [userId:money] with positive for who paid
    let description: String? // should be provided
    let image: String? // optional
}

struct FIRGroup: Codable, Identifiable {
    let id: String
    let title: String
    let users: [String]
    let transactions: [String]
    let currencyCode: String?
}

// MARK: - Arbitrary JSON Format

struct ExportData: Codable {
    let users: [ExportUser]
    let groups: [ExportGroup]
}

struct ExportUser: Codable {
    let name: String
    let email: String // identified by email
}

struct ExportTransaction: Codable {
    let id: String
    let expenses: [String: Double] // [email:money] with positive for who paid
}

struct ExportGroup: Codable {
    let id: String
    let title: String
    let users: [String] // emails of users
    let transactions: [ExportTransaction]
}
