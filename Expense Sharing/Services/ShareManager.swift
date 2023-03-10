//
//  ShareManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI

class ShareManager {
    static func exportUser(_ user: User, includeGroups: Bool, fileName: String) -> [AnyObject] {
        let userGroups = includeGroups ? DBManager.shared.getGroups(for: user.email) : []
        let exportData = ExportData(users: [user], groups: userGroups)
        return getShareActivities(exportData, fileName: fileName)
    }
    
    static func exportGroup(_ group: Group, includeUsers: Bool, fileName: String) -> [AnyObject] {
        let groupUsers = includeUsers ? group.users.compactMap({ DBManager.shared.getUser(by: $0) }) : []
        let exportData = ExportData(users: groupUsers, groups: [group])
        return getShareActivities(exportData, fileName: fileName)
    }
    
    static func getShareActivities(_ exportData: ExportData, fileName: String) -> [AnyObject] {
        var activities = [AnyObject]()
        if let url = JSONManager.saveToFile(exportData, named: fileName) {
            activities.append(url as AnyObject)
        }
        return activities
    }
}
