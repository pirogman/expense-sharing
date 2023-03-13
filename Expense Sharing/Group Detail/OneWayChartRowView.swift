//
//  OneWayChartRowView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 13.03.2023.
//

import SwiftUI

struct OneWayChartRowView: View {
    let barColor: Color
    let barWidth: CGFloat
    let barText: String
    let textColor: Color
    let putTextOverBar: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(barColor)
                    .frame(width: barWidth)
                    .overlay(alignment: .trailing) {
                        Text(barText)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 4)
                            .opacity(putTextOverBar ? 1 : 0)
                    }
                if !putTextOverBar {
                    Text(barText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                }
                Spacer()
            }
        }
        .lineLimit(1)
    }
}
