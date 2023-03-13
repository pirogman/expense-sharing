//
//  TwoWayChartRowView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 13.03.2023.
//

import SwiftUI

struct TwoWayChartRowView: View {
    let barHeight: CGFloat
    let barColor: Color
    let leftWidth: CGFloat
    let rightWidth: CGFloat
    let textColor: Color
    let leftText: String
    let rightText: String
    let widthForText: CGFloat
    
    var putLeftTextOverBar: Bool { widthForText < leftWidth }
    var putRightTextOverBar: Bool { widthForText < rightWidth }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                if !putLeftTextOverBar {
                    Text(leftText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                }
                Rectangle()
                    .fill(barColor)
                    .frame(width: leftWidth, height: barHeight)
                    .overlay(alignment: .leading) {
                        Text(leftText)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 4)
                            .opacity(putLeftTextOverBar ? 1 : 0)
                    }
            }
            
            HStack(spacing: 0) {
                Rectangle()
                    .fill(barColor)
                    .frame(width: rightWidth, height: barHeight)
                    .overlay(alignment: .trailing) {
                        Text(rightText)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 4)
                            .opacity(putRightTextOverBar ? 1 : 0)
                    }
                if !putRightTextOverBar {
                    Text(rightText)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                }
                Spacer()
            }
        }
        .lineLimit(1)
        .font(.caption)
    }
    
    private func textView(for text: String) -> some View {
        Text(text)
            .foregroundColor(textColor)
            .padding(.horizontal, 4)
    }
}
