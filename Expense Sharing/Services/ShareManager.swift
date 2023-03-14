//
//  ShareManager.swift
//  Expense Sharing
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
    
    static func getShareActivities(_ image: UIImage, fileName: String) -> [AnyObject] {
        var activities = [AnyObject]()
        if let url = saveToFile(image, named: fileName) {
            activities.append(url as AnyObject)
        }
        return activities
    }
    
    static func clearSharedFile(named: String) {
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(named)")
            try FileManager.default.removeItem(at: url)
        } catch let error {
            print("Removing file error: \(error)")
        }
    }
    
    static private func saveToFile(_ image: UIImage, named: String) -> URL? {
        guard let imageData = image.pngData() else { return nil }
        do {
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(named).png")
            try imageData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
