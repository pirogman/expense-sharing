//
//  CustomNavigationBar.swift
//  Expense Sharing
//

import SwiftUI

struct CustomNavigationBar<MenuContent: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let addBackButton: Bool
    let menuContent: MenuContent
    
    init(title: String, addBackButton: Bool, @ViewBuilder menuContentBuilder: () -> MenuContent) {
        self.title = title
        self.addBackButton = addBackButton
        self.menuContent = menuContentBuilder()
    }
    
    var body: some View {
        HStack {
            if addBackButton {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "chevron.left")
                            .resizable().scaledToFit()
                            .squareFrame(side: 16)
                            .padding(.horizontal, 8)
                        Text(title)
                            .font(.largeTitle)
                            .lineLimit(1)
                    }
                }
            } else {
                Text(title)
                    .font(.largeTitle)
                    .lineLimit(1)
            }
            Spacer()
            Menu {
                menuContent
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .resizable().scaledToFit()
                    .squareFrame(side: 24)
            }
        }
    }
}
