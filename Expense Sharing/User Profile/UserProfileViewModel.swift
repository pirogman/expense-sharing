//
//  UserProfileViewModel.swift
//  Expense Sharing
//

import SwiftUI
import FirebaseDatabase
import FirebaseDatabaseSwift

class UserProfileViewModel: ObservableObject {
    @Published private(set) var hint: String?
    
    @Published private(set) var name = "name"
    @Published private(set) var email = "email"
    @Published private(set) var groups = [FIRGroup]()
    
    @Published var searchText = "" {
        didSet { updateSearchGroups() }
    }
    @Published private(set) var searchGroups = [FIRGroup]()
    
    let userId: String
    
    private var observeUserHandler: UInt!
    
    init(_ userId: String) {
        self.userId = userId
        
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(userId)
        observeUserHandler = userRef.observe(.value) { [weak self] snapshot in
            guard let user = FIRUser(snapshot: snapshot) else { return }
            self?.update(on: user)
        }
    }
    
    deinit {
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: observeUserHandler)
    }
    
    private func update(on user: FIRUser) {
        print("update on user")
        name = user.name
        email = user.email
        FIRManager.shared.getGroupsFor(userId: user.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userGroups):
                self.groups = userGroups
                self.updateSearchGroups()
            case .failure(let error):
                print("failed to get groups for user with error: \(error)")
                break
            }
        }
    }
    
    private func updateSearchGroups() {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if search.isEmpty {
            searchGroups = groups
        } else {
            searchGroups = groups.filter { $0.title.lowercased().contains(search) }
        }
    }
    
    func editName(_ name: String, completion: @escaping VoidResultBlock) {
        guard let validName = Validator.validateUserName(name) else {
            return completion(.failure(ValidationError.invalidUserName))
        }
        hint = "Changing user name..."
        FIRManager.shared.editUser(name: validName, userId: userId, completion: completion)
    }
    
    func leaveGroup(_ group: FIRGroup, completion: @escaping VoidResultBlock) {
        hint = "Leaving group..."
        FIRManager.shared.leaveGroup(userId: userId, groupId: group.id, completion: completion)
    }
}
