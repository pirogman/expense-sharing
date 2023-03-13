//
//  UserAddGroupViewModel.swift
//  Expense Sharing
//

import SwiftUI

class UserAddGroupViewModel: ObservableObject {
    @Published private(set) var knownUsers = [User]()
    
    let user: User
    
    init(_ user: User) {
        self.user = user
    }
    
    func updateKnownUsers(search: String? = nil) {
        knownUsers = DBManager.shared.getUsers(excludeEmails: [user.email], search: search)
    }
    
    func createGroup(title: String, users: [User]) -> Result<String, Error> {
        guard let validTitle = Validator.validateGroupTitle(title) else {
            return .failure(ValidationError.invalidGroupTitle)
        }
        
        let emails = [user.email] + users.map({ $0.email })
        DBManager.shared.addNewGroup(title: validTitle, userEmails: emails)
        return .success(validTitle)
    }
}
