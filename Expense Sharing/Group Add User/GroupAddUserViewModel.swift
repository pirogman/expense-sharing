//
//  GroupAddUserViewModel.swift
//  Expense Sharing
//

import SwiftUI

class GroupAddUserViewModel: ObservableObject {
    @Published private(set) var hint: String?
    
    @Published private(set) var searchUsers = [FIRUser]()
    
    let groupId: String
    let groupTitle: String
    let excludeIds: [String]
    
    init(groupId: String, groupTitle: String, excludeIds: [String]) {
        self.groupId = groupId
        self.groupTitle = groupTitle
        self.excludeIds = excludeIds
    }
    
    func updateKnownUsers(search: String? = nil) {
        guard let search = search?.trimmingCharacters(in: .whitespacesAndNewlines), !search.isEmpty else {
            searchUsers = []
            return
        }
        FIRManager.shared.searchUsers(search) { [weak self] result in
            switch result {
            case .success(let users):
                let exclude = self?.excludeIds ?? []
                self?.searchUsers = users.filter { !exclude.contains($0.id) }
            case .failure(let error):
                print("search users failed with error: \(error)")
                self?.searchUsers = []
            }
        }
    }
    
    func addUsers(_ users: [FIRUser], completion: @escaping VoidResultBlock) {
        let userIds = users.map { $0.id }
        hint = "Inviting users..."
        FIRManager.shared.inviteUsersTo(groupId: groupId, userIds: userIds, completion: completion)
    }
}
