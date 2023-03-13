//
//  Validator.swift
//  Expense Sharing
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case invalidUserEmail, invalidUserName, invalidGroupTitle, invalidTransactionDescription
    
    public var errorDescription: String? {
        switch self {
        case .invalidUserEmail: return "Invalid email. Please, provide a valid email address."
        case .invalidUserName: return "Invalid name. Please, provide a name with at least 3 characters."
        case .invalidGroupTitle: return "Invalid title. Please, provide a title with at least 1 character."
        case .invalidTransactionDescription: return "Invalid description. Please provide at least 1 character, but not more than 120."
        }
    }
}

class Validator {
    static private let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    static func validateUserEmail(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        let range = NSMakeRange(0, NSString(string: trimmed).length)
        let matches = linkDetector.matches(in: trimmed, options: [], range: range)

        if matches.count == 1, matches.first?.url?.absoluteString.contains("mailto:") == true {
            return trimmed
        }
        return nil
    }
    
    static func validateUserName(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        if trimmed.count > 2 {
            return trimmed
        }
        return nil
    }
    
    static func validateGroupTitle(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        if trimmed.count > 0 {
            return trimmed
        }
        return nil
    }
    
    static func validateTransactionDescription(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        
        if Range(1...120).contains(trimmed.count) {
            return trimmed
        }
        return nil
    }
}
