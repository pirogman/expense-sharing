//
//  UserAddGroupView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 09.03.2023.
//

import SwiftUI

struct UserAddGroupView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var vm: UserAddGroupViewModel
    
    @State var groupTitle = ""
    @State var groupMembers = [User]()
    
    @State var showingSearch = false
    @State var searchText = ""
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            navigationBar
            groupSection
            CapsuleDivider()
            addUsersSection
        }
        .appBackgroundGradient()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            vm.updateKnownUsers()
        }
        .onChange(of: searchText) { text in
            withAnimation {
                vm.updateKnownUsers(search: text)
            }
        }
    }
    
    private var navigationBar: some View {
        AddOptionNavigationBar(
            title: "Add Group",
            cancelAction: {
                presentationMode.wrappedValue.dismiss()
            },
            confirmAction: {
                switch vm.createGroup(title: groupTitle, users: groupMembers) {
                case .success:
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        )
    }
    
    private var groupSection: some View {
        VStack {
            // Group title
            VStack(alignment: .leading) {
                TextField("Title", text: $groupTitle)
                    .textContentType(.name)
                    .stylishTextField()
                    .onSubmit {
                        hideKeyboard()
                    }
                Text(" Should contain at least 1 character.")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 32)
            
            // Group members
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if groupMembers.isEmpty {
                        Text("No selected users except you.")
                            .padding(.horizontal, 16)
                    } else {
                        ForEach(groupMembers) { user in
                            NewGroupMemberItemView(user: user)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation {
                                        toggleSelect(on: user)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .maskScrollEdges(startPoint: .leading, endPoint: .trailing)
            .frame(height: groupMembers.isEmpty ? 36 : 72)
        }
    }
    
    private var addUsersSection: some View {
        VStack(spacing: 0) {
            SearchOptionHeaderView(title: "Add Users", searchHint: " Find registered users by name or email.", showingSearch: $showingSearch, searchText: $searchText)
                .padding(.horizontal, 32)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.knownUsers.isEmpty {
                        Text(searchText.hasText
                             ? "No users matching search."
                             : "No users.")
                    } else {
                        ForEach(vm.knownUsers) { user in
                            VStack(spacing: 0) {
                                if vm.knownUsers.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                let isSelected = groupMembers.contains(where: { $0.id == user.id })
                                SearchUserItemView(user: user, isSelected: isSelected)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            toggleSelect(on: user)
                                        }
                                    }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.knownUsers.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
        }
    }
    
    private func toggleSelect(on user: User) {
        if let index = groupMembers.firstIndex(where: { $0.id == user.id }) {
            groupMembers.remove(at: index)
        } else {
            groupMembers.append(user)
        }
    }
}

struct CapsuleDivider: View {
    var body: some View {
        Capsule()
            .fill()
            .frame(height: 2)
            .padding(.horizontal, 16)
    }
}

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

struct CustomNavigationBar<MenuContent: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let addBackButton: Bool
    let backButtonTitle: String?
    let addMenuButton: Bool
    let menuContent: MenuContent
    
    init(title: String, addBackButton: Bool = true, backButtonTitle: String? = nil) where MenuContent == EmptyView {
        self.init(title: title, addBackButton: addBackButton, backButtonTitle: backButtonTitle, addMenuButton: false) { EmptyView() }
    }
    
    init(title: String, addBackButton: Bool = true, backButtonTitle: String? = nil, @ViewBuilder menuContentBuilder: () -> MenuContent) {
        self.init(title: title, addBackButton: addBackButton, backButtonTitle: backButtonTitle, addMenuButton: true, menuContentBuilder: menuContentBuilder)
    }
    
    private init(title: String, addBackButton: Bool, backButtonTitle: String?, addMenuButton: Bool, @ViewBuilder menuContentBuilder: () -> MenuContent) {
        self.title = title
        self.addBackButton = addBackButton
        self.backButtonTitle = backButtonTitle
        self.addMenuButton = addMenuButton
        self.menuContent = menuContentBuilder()
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            if addBackButton {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "chevron.left")
                            .resizable().scaledToFit()
                            .squareFrame(side: 16)
                            .padding(4)
                        if let backTitle = backButtonTitle {
                            Text(backTitle)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
            }
            Text(title).font(.largeTitle)
            Spacer()
            if addMenuButton {
                Menu {
                    menuContent
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable().scaledToFit()
                        .squareFrame(side: 24)
                }
            }
        }
        .padding(.leading, addBackButton ? 0 : 32)
        .padding(.trailing, addMenuButton  ? 32 : 8)
    }
}

struct SearchOptionHeaderView: View {
    let title: String
    let searchPrompt: String
    let searchHint: String?
    
    @Binding var showingSearch: Bool
    @Binding var searchText: String
    
    init(title: String, searchPrompt: String = "Search...", searchHint: String? = nil, showingSearch: Binding<Bool>, searchText: Binding<String>) {
        self.title = title
        self.searchPrompt = searchPrompt
        self.searchHint = searchHint
        self._showingSearch = showingSearch
        self._searchText = searchText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.title)
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
                TextField(searchPrompt, text: $searchText)
                    .textContentType(.name)
                    .stylishTextField()
                    .onSubmit {
                        hideKeyboard()
                    }
                    .padding(.bottom, searchHint == nil ? 4 : 0)
                
                if let hint = searchHint {
                    Text(hint)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                }
            }
        }
    }
}