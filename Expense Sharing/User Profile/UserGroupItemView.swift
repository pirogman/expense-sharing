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
        .offset(x: offset, y: 0)
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
                            .squareFrame(side: trashSize)
                            .padding(.trailing, deleteOnRelease
                                     ? abs(dragOffset.width / 2)
                                     : (keepDeleteDistance - trashSize) / 2)
                            .opacity(showDelete ? 1 : 0)
                            .scaleEffect(deleteScale)
                    }
            }
            .frame(width: abs(offset))
        }
        .animation(.interactiveSpring(), value: offset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, transaction in
                    state = value.translation
                }
                .updating($isDragging) { value, state, translation in
                    state = true
                }
        )
        .onChange(of: dragOffset) { offset in
            if isDragging {
                // In process
                showDelete = offset.width < -showDeleteDistance
                keepDelete = offset.width < -keepDeleteDistance
                deleteOnRelease = offset.width < -deleteOnReleaseDistance

                if showDelete {
                    let scale = (abs(offset.width) - showDeleteDistance) / showDeleteDistance
                    deleteScale = min(maxDeleteScale, max(scale, minDeleteScale))
                } else {
                    deleteScale = minDeleteScale
                }
            } else {
                // Ended
                if deleteOnRelease {
                    // Do the delete and reset if swiped to much
                    onDelete()
                    reset()
                } else if keepDelete {
                    // Keep delete button if swiped enough
                    deleteOffset = CGSize(width: -keepDeleteDistance, height: 0)
                    deleteScale = maxDeleteScale
                } else {
                    // Hide delete button on incomplete swipe
                    reset()
                }
            }
        }
    }
    
    // MARK: - Swipe To Delete
    
    private let showDeleteDistance: CGFloat = 30
    private let keepDeleteDistance: CGFloat = 60
    private let deleteOnReleaseDistance: CGFloat = 180
    private let minDeleteScale: CGFloat = 0.25
    private let maxDeleteScale: CGFloat = 1.0
    private let trashSize: CGFloat = 18
    
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var isDragging: Bool = false
    
    @State private var deleteOffset: CGSize = .zero
    @State private var showDelete: Bool = false
    @State private var keepDelete: Bool = false
    @State private var deleteOnRelease: Bool = false
    @State private var deleteScale: CGFloat = 0.25
    
    var offset: CGFloat {
        let width = dragOffset.width < 0 ? abs(dragOffset.width) : abs(deleteOffset.width)
        return -width
    }
    
    private func reset() {
        deleteOffset = .zero
        showDelete = false
        keepDelete = false
        deleteOnRelease = false
        deleteScale = minDeleteScale
    }
}
