//
//  AuthViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
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

class AuthViewModel: ObservableObject {
    func getDBCounts() -> (Int, Int) {
        return (DBManager.shared.users.count, DBManager.shared.groups.count)
    }
    
    func registerUser(name: String, email: String) -> Result<User, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(ValidationError.invalidName)
        }
        guard let validEmail = Validator.validateEmail(email) else {
            return .failure(ValidationError.invalidEmail)
        }
        if let user = DBManager.shared.addUser(name: validName, email: validEmail) {
            return .success(user)
        }
        return .failure(AuthError.alreadyRegistered)
    }
    
    func loginUser(email: String) -> Result<User, Error> {
        guard let validEmail = Validator.validateEmail(email) else {
            return .failure(ValidationError.invalidEmail)
        }
        guard let user = DBManager.shared.getUser(by: validEmail) else {
            return .failure(AuthError.notRegistered)
        }
        return .success(user)
    }
    
    let allowedContentTypes = [UTType.json]
    let allowsMultipleSelection = false
    
    func handleSelectingFile(_ result: Result<[URL], Error>) -> Result<(Int, Int), Error> {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    let data = JSONManager.loadFrom(fileURL: url)
                    DBManager.shared.importData(data)
                    return .success((data.users.count, data.groups.count))
                }
            }
            return .failure(URLError.cannotOpenFile as! Error)
        case .failure(let error):
            return .failure(error)
        }
    }
}
