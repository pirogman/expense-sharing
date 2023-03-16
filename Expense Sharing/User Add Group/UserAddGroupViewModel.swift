//
//  UserAddGroupViewModel.swift
//  Expense Sharing
//

import SwiftUI

class UserAddGroupViewModel: ObservableObject {
    @Published private(set) var hint: String?
    
    @Published private(set) var searchUsers = [FIRUser]()
    
    let userId: String
    
    init(_ userId: String) {
        self.userId = userId
    }
    
    func updateKnownUsers(search: String? = nil) {
        guard let search = search?.trimmingCharacters(in: .whitespacesAndNewlines), !search.isEmpty else {
            searchUsers = []
            return
        }
        FIRManager.shared.searchUsers(search) { [weak self] result in
            switch result {
            case .success(let users):
                self?.searchUsers = users
            case .failure(let error):
                print("search users failed with error: \(error)")
                self?.searchUsers = []
            }
        }
    }
    
    func createGroup(title: String, users: [FIRUser], completion: @escaping VoidResultBlock) {
        guard let validTitle = Validator.validateGroupTitle(title) else {
            completion(.failure(ValidationError.invalidGroupTitle))
            return
        }
        let meWithOthers = [userId] + users.map { $0.id }
        let newGroup = FIRGroup(id: UUID().uuidString, title: validTitle, users: meWithOthers, transactions: [], currencyCode: nil)
        hint = "Creating group..."
        FIRManager.shared.createGroup(newGroup, completion: completion)
    }
}
