//
//  CurrencyManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 11.03.2023.
//

import SwiftUI

class CurrencyManager {
    static private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    static private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        return formatter
    }()
    
    static func getText(for money: Double, currencyCode: String? = nil) -> String {
        currencyFormatter.currencyCode = currencyCode
        return currencyFormatter.string(from: NSNumber(value: money)) ?? "NaN"
    }
    
    static func getNumber(from text: String) -> Double {
        currencyFormatter.currencyCode = nil
        if let currencyNumber = currencyFormatter.number(from: text) {
            return Double(truncating: currencyNumber)
        } else if let justNumber = numberFormatter.number(from: text) {
            return Double(truncating: justNumber)
        } else {
            return 0.0
        }
    }
}
