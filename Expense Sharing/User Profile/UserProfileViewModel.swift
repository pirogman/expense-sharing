//
//  UserProfileViewModel.swift
//  Expense Sharing
//

import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published private(set) var name: String = "name"
    @Published private(set) var email: String = "email"
    @Published private(set) var userGroups = [FIRGroup]()
    
    let userId: String
    
    init(_ userId: String) {
        self.userId = userId
    }
    
    func updateUserGroups(search: String? = nil) {
//        userGroups = DBManager.shared.getGroups(for: email, search: search)
    }
    
    func editName(_ name: String) -> Result<Void, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(ValidationError.invalidUserName)
        }
        self.name = validName
        return .success(())
    }
    
    func deleteGroup(_ group: FIRGroup) {
//        DBManager.shared.removeGroup(byId: group.id)
//        userGroups.removeAll(where: { $0.id == group.id })
    }
}
