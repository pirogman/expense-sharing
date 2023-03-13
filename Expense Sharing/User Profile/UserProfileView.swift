//
//  UserProfileView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appManager: AppManager
    
    @StateObject var vm: UserProfileViewModel
    
    @State var isLoading = false
    
    @State var navigateToSelectedGroup = false
    @State var selectedGroup: Group?
    
    @State var showingEditNameAlert = false
    @State var editedName = ""
    
    @State var showingAddGroup = false
    @State var showingUserShare = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var showingSearch = false
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Navigation
                NavigationLink(isActive: $navigateToSelectedGroup) {
                    if let group = selectedGroup {
                        let vm = GroupDetailViewModel(group: group, forUserEmail: vm.email)
                        GroupDetailView(vm: vm)
                    } else {
                        Text("No Such Group")
                            .onAppear {
                                navigateToSelectedGroup = false
                            }
                    }
                } label: { EmptyView() }
                
                profileSection
                CapsuleDivider()
                groupsSection
            }
            .coverWithLoader(isLoading)
            .appBackgroundGradient()
            .navigationBarHidden(true)
            .onAppear {
                vm.updateUserGroups()
            }
            .onChange(of: searchText) { text in
                withAnimation {
                    vm.updateUserGroups(search: text)
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
            .fullScreenCover(
                isPresented: $showingAddGroup,
                onDismiss: { vm.updateUserGroups(search: searchText) },
                content: { UserAddGroupView(vm: UserAddGroupViewModel(vm.user)) }
            )
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Profile", addBackButton: false) {
                Button {
                    editedName = vm.user.name
                    showingEditNameAlert = true
                } label: {
                    Label("Edit Name", systemImage: "square.and.pencil")
                }
                Button {
                    showingAddGroup = true
                } label: {
                    Label("Add Group", systemImage: "plus.square")
                }
                Button {
                    showingUserShare = true
                } label: {
                    Label("Share User", systemImage: "square.and.arrow.up")
                }
                Button {
                    appManager.appState = .unauthorised
                } label: {
                    Label("Leave", systemImage: "arrow.left.square")
                }
            }
            .padding(.horizontal, 16)
            
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
            .padding(.horizontal, 32)
        }
    }
    
    private var groupsSection: some View {
        VStack(spacing: 0) {
            SearchOptionHeaderView(title: "Groups", showingSearch: $showingSearch, searchText: $searchText)
                .padding(.horizontal, 32)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.userGroups.isEmpty {
                        Text(searchText.hasText
                             ? "No groups matching search."
                             : "No groups.")
                    } else {
                        ForEach(vm.userGroups) { group in
                            VStack(spacing: 0) {
                                if vm.userGroups.first?.id != group.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                SwipeToRemoveItemView() {
                                    UserGroupItemView(groupTitle: group.title, groupUsersCount: group.users.count)
                                } onSelect: {
                                    withAnimation {
                                        selectedGroup = group
                                        navigateToSelectedGroup = true
                                    }
                                } onDelete: {
                                    withAnimation {
                                        vm.deleteGroup(group)
                                    }
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.userGroups.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
        }
    }
}
