//
//  GroupDetailSections.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

// MARK: - Chats Section

struct GroupDetailChartView: View {
    let centerText: String
    
    var body: some View {
        HStack {
            Spacer()
            Circle()
                .foregroundColor(.red)
                .squareFrame(side: UIScreen.main.bounds.width * 0.6)
                .overlay(
                    Text(centerText).bold()
                        .squareFrame(side: UIScreen.main.bounds.width * 0.35)
                        .background(
                            Circle().foregroundColor(.white)
                        )
                )
            Spacer()
        }
    }
}
