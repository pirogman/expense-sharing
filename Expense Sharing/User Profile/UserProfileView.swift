//
//  UserProfileView.swift
//  Expense Sharing
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appManager: AppManager
    
    @StateObject var vm: UserProfileViewModel
    
    @State var isLoading = false
    
    @State var navigateToSelectedGroup = false
    @State var selectedGroup: FIRGroup?
    
    @State var showingEditNameAlert = false
    @State var editedName = ""
    
    @State var showingAddGroup = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var showingSearch = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Navigation
                NavigationLink(isActive: $navigateToSelectedGroup) {
                    if let group = selectedGroup {
                        let viewModel = GroupDetailViewModel(groupId: group.id, forUserId: vm.userId)
                        GroupDetailView(vm: viewModel)
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
            .appBackgroundGradient()
            .coverWithLoader(isLoading, hint: vm.hint)
            .navigationBarHidden(true)
            .textFieldAlert(isPresented: $showingEditNameAlert, title: "Edit Name", message: "User name should consist of at least 3 characters.", placeholder: "Name", input: $editedName) {
                withAnimation { isLoading = true }
                vm.editName(editedName) { result in
                    withAnimation { isLoading = false }
                    switch result {
                    case .success: break
                    case .failure(let error):
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
            .fullScreenCover(
                isPresented: $showingAddGroup,
                content: { UserAddGroupView(vm: UserAddGroupViewModel(vm.userId)) }
            )
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "Profile", addBackButton: false) {
                Button {
                    editedName = vm.name
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
                    appManager.appState = .unauthorised
                } label: {
                    Label("Leave", systemImage: "arrow.left.square")
                }
            }
            .padding(.horizontal, 16)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(vm.name)
                        .font(.headline)
                    Text(vm.email)
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
            SearchOptionHeaderView(title: "Groups", showingSearch: $showingSearch, searchText: $vm.searchText)
                .padding(.horizontal, 32)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.searchGroups.isEmpty {
                        Text(vm.searchText.hasText
                             ? "No groups matching search."
                             : "No groups.")
                    } else {
                        ForEach(vm.searchGroups) { group in
                            VStack(spacing: 0) {
                                if vm.searchGroups.first?.id != group.id {
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
                                        isLoading = true
                                        vm.leaveGroup(group) { result in
                                            isLoading = false
                                            switch result {
                                            case .success: break
                                            case .failure(let error):
                                                alertTitle = "Error"
                                                alertMessage = error.localizedDescription
                                                showingAlert = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.searchGroups.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .animation(.default, value: vm.searchGroups.count)
        }
    }
}
