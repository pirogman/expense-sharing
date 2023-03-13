//
//  ExpenseCalculator.swift
//  Expense Sharing
//

import Foundation

/// Format: amount to transfer, index of who paid, index of who received
typealias CashFlowAction = (Double, Int, Int)

class ExpenseCalculator {
    static func calculateCashFlow(in array: [Double]) -> [CashFlowAction] {
        guard !array.isEmpty else { return [] }
        return calculateCashFlowRecursively(in: array, actions: []).1
    }
    
    static private func calculateCashFlowRecursively(in array: [Double], actions: [CashFlowAction]) -> ([Double], [CashFlowAction]) {
        var cashArray = array
        var cashActions = actions
        
        // Get paying and receiving items
        let maxDebitIndex = getMinValueIndex(in: array)
        let maxCreditIndex = getMaxValueIndex(in: array)
        let maxDebit = array[maxDebitIndex]
        let maxCredit = array[maxCreditIndex]
        
        guard maxDebit < 0 && maxCredit > 0 else {
            // Calculated to the end, return
            return (cashArray, cashActions)
        }
        
        // Transfer cash
        let cash = min(abs(maxDebit), maxCredit)
        cashArray[maxDebitIndex] += cash
        cashArray[maxCreditIndex] -= cash
        cashActions.append((cash, maxCreditIndex, maxDebitIndex))
        
        // Continue until finished
        return calculateCashFlowRecursively(in: cashArray, actions: cashActions)
    }
    
    static private func getMinValueIndex(in array: [Double]) -> Int {
        var index = 0
        for i in 0..<array.count {
            if array[i] < array[index] {
                index = i
            }
        }
        return index
    }
    
    static private func getMaxValueIndex(in array: [Double]) -> Int {
        var index = 0
        for i in 0..<array.count {
            if array[i] > array[index] {
                index = i
            }
        }
        return index
    }
}
