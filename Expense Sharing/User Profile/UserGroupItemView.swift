//
//  UserGroupItemView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 09.03.2023.
//

import SwiftUI

struct UserGroupItemView: View {
    let group: Group
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    init(_ group: Group, onSelect: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.group = group
        self.onSelect = onSelect
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(group.title)
                    .font(.headline)
                Text("\(group.users.count) user(s)")
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable().scaledToFit()
                .squareFrame(side: 12)
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .offset(x: min(offset.width, 0), y: 0)
        .contentShape(Rectangle())
        .clipped()
        .onTapGesture {
            onSelect()
            reset()
        }
        .overlay(alignment: .trailing) {
            Button {
                onDelete()
                reset()
            } label: {
                Color.red
                    .overlay(alignment: .trailing) {
                        Image(systemName: "trash")
                            .resizable().scaledToFit()
                            .squareFrame(side: 18)
                            .padding(.trailing, deleteOnRelease ? abs(offset.width / 2): (keepDeleteDistance - 18) / 2)
                            .opacity(showDelete ? 1 : 0)
                            .scaleEffect(deleteScale)
                    }
            }
            .frame(width: offset.width < 0 ? abs(offset.width) : 0)
        }
        .animation(.interactiveSpring(), value: offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Drop first change as this gesture may be intercepted by ScrollView
                    guard firstChangeDropped else {
                        print("first change")
                        firstChangeDropped = true
                        return
                    }
                    print("other change")
                    
                    offset = gesture.translation
                    
                    showDelete = offset.width < -showDeleteDistance
                    keepDelete = offset.width < -keepDeleteDistance
                    deleteOnRelease = offset.width < -deleteOnReleaseDistance
                    
                    if showDelete {
                        let scale = (abs(offset.width) - showDeleteDistance) / showDeleteDistance
                        deleteScale = min(maxDeleteScale, max(scale, minDeleteScale))
                    } else {
                        deleteScale = minDeleteScale
                    }
                }
                .onEnded { _ in
                    print("ended")
                    firstChangeDropped = false
                    
                    if deleteOnRelease {
                        // Do the delete and reset if swiped to much
                        onDelete()
                        reset()
                    } else if keepDelete {
                        // Keep delete button if swiped enough
                        offset = CGSize(width: -keepDeleteDistance, height: 0)
                        deleteScale = maxDeleteScale
                    } else {
                        // Hide delete button on incomplete swipe
                        reset()
                    }
                }
        )
    }
    
    // MARK: - Swipe To Delete
    
    private let showDeleteDistance: CGFloat = 30
    private let keepDeleteDistance: CGFloat = 60
    private let deleteOnReleaseDistance: CGFloat = 180
    private let minDeleteScale: CGFloat = 0.25
    private let maxDeleteScale: CGFloat = 1.0
    
    @State private var firstChangeDropped: Bool = false
    @State private var offset: CGSize = .zero
    @State private var showDelete: Bool = false
    @State private var keepDelete: Bool = false
    @State private var deleteOnRelease: Bool = false
    @State private var deleteScale: CGFloat = 0.25
    
    private func reset() {
        offset = .zero
        showDelete = false
        keepDelete = false
        deleteOnRelease = false
        deleteScale = minDeleteScale
    }
}
