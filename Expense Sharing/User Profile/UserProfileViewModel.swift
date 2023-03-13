//
//  UserProfileViewModel.swift
//  Expense Sharing
//

import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published private(set) var name: String
    @Published private(set) var userGroups = [Group]()
    
    var user: User { User(name: name, email: email) }
    
    let email: String
    
    init(_ user: User) {
        self.email = user.email
        self.name = user.name
    }
    
    func updateUserGroups(search: String? = nil) {
        userGroups = DBManager.shared.getGroups(for: email, search: search)
    }
    
    func editName(_ name: String) -> Result<Void, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(ValidationError.invalidUserName)
        }
        
        DBManager.shared.editUser(by: email, name: validName)
        self.name = validName
        return .success(())
    }
    
    func deleteGroup(_ group: Group) {
        DBManager.shared.removeGroup(byId: group.id)
        userGroups.removeAll(where: { $0.id == group.id })
    }
    
    // MARK: - Share
    
    private var tempFileName: String?
    
    func getUserShareActivities() -> [AnyObject] {
        tempFileName = name.replacingOccurrences(of: " ", with: "_")
        return ShareManager.exportUser(user, includeGroups: true, fileName: tempFileName!)
    }
    
    func clearSharedUserFile() {
        guard let name = tempFileName else { return }
        tempFileName = nil
        JSONManager.clearTempFile(named: name)
    }
}
