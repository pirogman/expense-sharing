//
//  GroupAddUserViewModel.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI

class GroupAddUserViewModel: ObservableObject {
    @Published private(set) var knownUsers = [User]()
    
    let group: Group
    
    init(_ group: Group) {
        self.group = group
    }
    
    func updateKnownUsers(search: String? = nil) {
        knownUsers = DBManager.shared.getUsers(excludeEmails: group.users, search: search)
    }
    
    func addUsers(users: [User]) -> Result<Int, Error> {
        let emails = group.users + users.map({ $0.email })
        DBManager.shared.editGroup(byId: group.id, users: emails)
        return .success(users.count)
    }
}
