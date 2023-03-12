//
//  AddOptionNavigationBar.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct AddOptionNavigationBar: View {
    let title: String
    let addSideTitles: Bool
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    
    init(title: String, addSideTitles: Bool = true, cancelAction: @escaping () -> Void, confirmAction: @escaping () -> Void) {
        self.title = title
        self.addSideTitles = addSideTitles
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }
    
    var body: some View {
        HStack {
            Button(action: cancelAction) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark")
                        .resizable().scaledToFit()
                        .squareFrame(side: 16)
                        .padding(.vertical, 4)
                    if addSideTitles {
                        Text("Cancel")
                    }
                }
                .padding(.horizontal, 8)
            }
            Spacer()
            Button(action: confirmAction) {
                HStack(spacing: 8) {
                    if addSideTitles {
                        Text("Confirm")
                    }
                    Image(systemName: "checkmark")
                        .resizable().scaledToFit()
                        .squareFrame(side: 16)
                        .padding(4)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
            }
        }
        .overlay {
            Text(title).bold()
        }
        .padding([.bottom, .horizontal], 8)
    }
}
