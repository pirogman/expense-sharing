//
//  SwipeToRemoveItemView.swift
//  Expense Sharing
//

import SwiftUI

struct SwipeToRemoveItemView<Content: View>: View {
    let content: Content
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    init(@ViewBuilder contentBuilder: () -> Content, onSelect: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.content = contentBuilder()
        self.onSelect = onSelect
        self.onDelete = onDelete
    }
    
    var body: some View {
        content
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
                        .overlay(alignment: deleteOnRelease ? .leading : .trailing) {
                            Image(systemName: "trash")
                                .resizable().scaledToFit()
                                .squareFrame(side: trashSize)
                                .padding(.leading, deleteOnRelease ? trashPadding : 0)
                                .padding(.trailing, !deleteOnRelease ? trashPadding : 0)
                                .opacity(showDelete ? 1 : 0)
                                .scaleEffect(deleteScale)
                        }
                        .animation(.interactiveSpring(), value: deleteOnRelease)
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
    
    private var trashPadding: CGFloat { (keepDeleteDistance - trashSize) / 2 }
    
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var isDragging: Bool = false
    
    @State private var deleteOffset: CGSize = .zero
    @State private var showDelete: Bool = false
    @State private var keepDelete: Bool = false
    @State private var deleteOnRelease: Bool = false
    @State private var deleteScale: CGFloat = 0.25
    
    private var offset: CGFloat {
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
