//
//  GroupAddUserView.swift
//  Expense Sharing
//

import SwiftUI

struct GroupAddUserView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var vm: GroupAddUserViewModel
    
    @State var isLoading = false
    
    @State var newMembers = [FIRUser]()
    @State var searchText = ""
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            navigationBar
            usersSection
        }
        .appBackgroundGradient()
        .coverWithLoader(isLoading, hint: vm.hint)
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: searchText) { text in
            withAnimation {
                newMembers.removeAll()
                vm.updateKnownUsers(search: text)
            }
        }
    }
    
    private var navigationBar: some View {
        AddOptionNavigationBar(
            title: "Add Users",
            cancelAction: {
                presentationMode.wrappedValue.dismiss()
            },
            confirmAction: {
                withAnimation { isLoading = true }
                vm.addUsers(newMembers) { result in
                    withAnimation { isLoading = false }
                    switch result {
                    case .success:
                        presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        alertTitle = "Error"
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            }
        )
    }
    
    private var usersSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(vm.groupTitle)
                    .font(.title)
                TextField("Search...", text: $searchText)
                    .textContentType(.name)
                    .stylishTextField()
                    .onSubmit {
                        hideKeyboard()
                    }
                Text("Find registered users by name or email.")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
            }
            .padding(.horizontal, 32)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.searchUsers.isEmpty {
                        Text(searchText.hasText
                             ? "No users matching search."
                             : "Please, start searching for users.")
                    } else {
                        ForEach(vm.searchUsers) { user in
                            VStack(spacing: 0) {
                                if vm.searchUsers.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                let isSelected = newMembers.contains(where: { $0.id == user.id })
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
                        .strokeBorder(vm.searchUsers.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .animation(.default, value: vm.searchUsers.count)
        }
    }
    
    private func toggleSelect(on user: FIRUser) {
        if let index = newMembers.firstIndex(where: { $0.id == user.id }) {
            newMembers.remove(at: index)
        } else {
            newMembers.append(user)
        }
    }
}
