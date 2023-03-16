//
//  UserAddGroupViewModel.swift
//  Expense Sharing
//

import SwiftUI

class UserAddGroupViewModel: ObservableObject {
    @Published private(set) var knownUsers = [FIRUser]()
    
    let user: FIRUser
    
    init(_ user: FIRUser) {
        self.user = user
    }
    
    func updateKnownUsers(search: String? = nil) {
        knownUsers = DBManager.shared.getUsers(excludeEmails: [user.email], search: search)
    }
    
    func createGroup(title: String, users: [FIRUser]) -> Result<String, Error> {
        guard let validTitle = Validator.validateGroupTitle(title) else {
            return .failure(ValidationError.invalidGroupTitle)
        }
        
        let emails = [user.email] + users.map({ $0.email })
        return .success(validTitle)
    }
}
