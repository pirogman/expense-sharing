//
//  DBManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 07.03.2023.
//

import SwiftUI

class DBManager {
    static let shared = DBManager()
    private init() { }
    
    private(set) var users = [User]()
    private(set) var groups = [Group]()
    
    func getUser(by email: String) -> User? {
        for user in users {
            if user.email == email {
                return user
            }
        }
        return nil
    }
    
    /// Adds new user to the DB if not already there, otherwise return `nil`
    func addUser(name: String, email: String) -> User? {
        guard getUser(by: email) == nil else {
            return nil
        }
        let newUser = User(name: name, email: email)
        users.append(newUser)
        return newUser
    }
    
    // MARK: - Groups
    
    func getGroups(for user: User) -> [Group] {
        groups.filter { $0.users.contains(user.email) }
    }
    
    // MARK: - Import
    
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
}

