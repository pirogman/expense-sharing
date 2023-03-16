//
//  GroupAddUserViewModel.swift
//  Expense Sharing
//

import SwiftUI

class GroupAddUserViewModel: ObservableObject {
    @Published private(set) var knownUsers = [FIRUser]()
    
    let groupId: String
    let groupTitle: String
    let excludeUserEmails: [String]
    
    init(groupId: String) {
        self.groupId = groupId
        
        let group = DBManager.shared.getGroup(byId: groupId)!
        self.groupTitle = group.title
        self.excludeUserEmails = group.users
    }
    
    init(group: FIRGroup) {
        self.groupId = group.id
        self.groupTitle = group.title
        self.excludeUserEmails = group.users
    }
    
    func updateKnownUsers(search: String? = nil) {
        knownUsers = DBManager.shared.getUsers(excludeEmails: excludeUserEmails, search: search)
    }
    
    func addUsers(users: [FIRUser]) -> Result<Int, Error> {
        let emails = excludeUserEmails + users.map({ $0.email })
        DBManager.shared.editGroup(byId: groupId, users: emails)
        return .success(users.count)
    }
}
