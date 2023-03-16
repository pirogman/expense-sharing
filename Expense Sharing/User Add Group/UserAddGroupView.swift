//
//  UserAddGroupView.swift
//  Expense Sharing
//

import SwiftUI

struct UserAddGroupView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var vm: UserAddGroupViewModel
    
    @State var groupTitle = ""
    @State var groupMembers = [FIRUser]()
    
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
                Text("Should contain at least 1 character.")
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
                            NewGroupMemberItemView(userName: user.name, userEmail: user.email)
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
                                SearchUserItemView(
                                    isSelected: isSelected,
                                    userName: user.name,
                                    userEmail: user.email
                                )
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
    
    private func toggleSelect(on user: FIRUser) {
        if let index = groupMembers.firstIndex(where: { $0.id == user.id }) {
            groupMembers.remove(at: index)
        } else {
            groupMembers.append(user)
        }
    }
}
