//
//  HideOptionHeaderView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct HideOptionHeaderView: View {
    let title: String
    @Binding var hideContent: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
            Spacer()
            Button {
                withAnimation {
                    hideContent.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .resizable().scaledToFit()
                    .squareFrame(side: 16)
                    .padding(4)
                    .rotationEffect(.degrees(hideContent ? -180 : 0))
                    .animation(.linear, value: hideContent)
            }
        }
    }
}
