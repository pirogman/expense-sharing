//
//  Validator.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 07.03.2023.
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case invalidEmail, invalidName
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Invalid email. Please, provide a valid email address."
        case .invalidName: return "Invalid name. Please, provide a name with at least 3 characters."
        }
    }
}

class Validator {
    static private let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    static func validateEmail(_ text: String?) -> String? {
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
}