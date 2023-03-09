//
//  UserProfileView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject var vm: UserProfileViewModel
    
    @State var navigateToAddGroup = false
    @State var navigateToSelectedGroup = false
    @State var selectedGroup: Group?
    
    @State var showingEditNameAlert = false
    @State var editedName = ""
    
    @State var showingUserShare = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var showingSearch = false
    @State var searchText = ""
    
    init(user: User) {
        self._vm = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Navigation
                NavigationLink(isActive: $navigateToAddGroup) {
                    Text("Add Group")
                } label: { EmptyView() }
                NavigationLink(isActive: $navigateToSelectedGroup) {
                    if let group = selectedGroup {
                        GroupDetailView(vm.getManagedGroup(from: group))
                    } else {
                        Text("No Such Group")
                    }
                } label: { EmptyView() }
                
                profileHeader
                    .padding(.horizontal, 32)
                userInfo
                    .padding(.horizontal, 32)
                
                Capsule()
                    .fill(Color.white)
                    .frame(height: 2)
                    .padding(.horizontal, 16)
                    .padding(.vertical)
                
                groupsHeader
                    .padding(.horizontal, 32)
                    .padding(.bottom, 4)
                groupsScroll
            }
            .appBackgroundGradient()
            .navigationBarHidden(true)
            .onAppear {
                vm.updateGroups()
            }
            .onChange(of: searchText) { text in
                withAnimation {
                    vm.updateGroups(search: text)
                }
            }
            .textFieldAlert(isPresented: $showingEditNameAlert, title: "Edit Name", message: "User name should consist of at least 3 characters.", placeholder: "Name", input: $editedName) {
                withAnimation {
                    switch vm.editName(editedName) {
                    case .success: break
                    case .failure(let error):
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
            .sheet(isPresented: $showingUserShare) {
                ActivityViewController(activityItems: vm.getUserShareActivities()) { _ in
                    vm.clearSharedUserFile()
                }
            }
        }
    }
    
    private var profileHeader: some View {
        HStack {
            Text("Profile")
                .font(.largeTitle)
            Spacer()
            Menu {
                Button {
                    editedName = vm.user.name
                    showingEditNameAlert = true
                } label: {
                    Label("Edit Name", systemImage: "square.and.pencil")
                }
                Button {
                    navigateToAddGroup = true
                } label: {
                    Label("Add Group", systemImage: "plus.square")
                }
                Button {
                    showingUserShare = true
                } label: {
                    Label("Share User", systemImage: "square.and.arrow.up")
                }
                Button {
                    AppManager.shared.appState = .unauthorised
                } label: {
                    Label("Leave", systemImage: "arrow.left.square")
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .resizable().scaledToFit()
                    .squareFrame(side: 24)
            }
        }
    }
    
    private var userInfo: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(vm.user.name)
                        .font(.headline)
                    Text(vm.user.email)
                        .font(.subheadline)
                }
                .lineLimit(1)
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private var groupsHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Groups")
                    .font(.title)
                Spacer()
                Button {
                    withAnimation {
                        showingSearch.toggle()
                        searchText = ""
                    }
                } label: {
                    Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                        .resizable().scaledToFit()
                        .squareFrame(side: showingSearch ? 12 : 18)
                        .padding(showingSearch ? 6 : 3)
                }
            }
            if showingSearch {
                TextField("Search...", text: $searchText)
                    .textContentType(.name)
                    .onSubmit {
                        hideKeyboard()
                    }
                    .stylishTextField()
            }
        }
    }
    
    private var groupsScroll: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 0) {
                if vm.groups.isEmpty {
                    Text("No groups yet.")
                } else {
                    ForEach(vm.groups) { group in
                            VStack(spacing: 0) {
                                if vm.groups.first?.id != group.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                UserGroupItemView(group) {
                                    selectedGroup = group
                                    navigateToSelectedGroup = true
                                } onDelete: {
                                    vm.deleteGroup(group)
                                }
                            }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(vm.groups.isEmpty ? .clear : .white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
//        .onTapGesture { /* Fix Tap Gesture Inside Scroll View */ }
        .mask(
            // Apply a mask to top and bottom in order to fade content away
            LinearGradient(gradient: Gradient(stops: [
                .init(color: .black.opacity(0), location: 0.0),
                .init(color: .black, location: 0.02),
                .init(color: .black, location: 0.96),
                .init(color: .black.opacity(0), location: 1.0),
            ]), startPoint: .top, endPoint: .bottom)
        )
    }
}

struct Delete: ViewModifier {
    
    let action: () -> Void
    
    @State var offset: CGSize = .zero
    @State var initialOffset: CGSize = .zero
    @State var contentWidth: CGFloat = 0.0
    @State var willDeleteIfReleased = false
   
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title2.bold())
                            .layoutPriority(-1)
                    }.frame(width: -offset.width)
                    .offset(x: geometry.size.width)
                    .onAppear {
                        contentWidth = geometry.size.width
                    }
                    .gesture(
                        TapGesture()
                            .onEnded {
                                delete()
                            }
                    )
                }
            )
            .offset(x: offset.width, y: 0)
            .gesture (
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width + initialOffset.width <= 0 {
                            self.offset.width = gesture.translation.width + initialOffset.width
                        }
                        if self.offset.width < -deletionDistance && !willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        } else if offset.width > -deletionDistance && willDeleteIfReleased {
                            hapticFeedback()
                            willDeleteIfReleased.toggle()
                        }
                    }
                    .onEnded { _ in
                        if offset.width < -deletionDistance {
                            delete()
                        } else if offset.width < -halfDeletionDistance {
                            offset.width = -tappableDeletionWidth
                            initialOffset.width = -tappableDeletionWidth
                        } else {
                            offset = .zero
                            initialOffset = .zero
                        }
                    }
            )
            .animation(.interactiveSpring(), value: offset)
    }
    
    private func delete() {
        offset.width = -contentWidth
        action()
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: Constants
    
    let deletionDistance = CGFloat(200)
    let halfDeletionDistance = CGFloat(50)
    let tappableDeletionWidth = CGFloat(100)
}

extension View {
    func onMyDelete(perform action: @escaping () -> Void) -> some View {
        self.modifier(Delete(action: action))
    }
}
