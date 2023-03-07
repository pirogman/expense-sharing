//
//  GroupDetailView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

struct GroupDetailView: View {
    @StateObject var vm: GroupDetailViewModel
    
    @State var editedTitle = ""
    @State var showingEditTitleAlert = false
    @State var showingAddUser = false
    @State var showingAddTransaction = false
    @State var showingGroupShare = false
    @State var selectedTransactionId: String?
    
    init(_ group: ManagedGroup) {
        self._vm = StateObject(wrappedValue: GroupDetailViewModel(group))
    }
    
    var body: some View {
        VStack {
            // Navigation
            NavigationLink(destination: GroupAddUserView(vm: vm), isActive: $showingAddUser) { EmptyView() }
            NavigationLink(destination: GroupAddTransactionView(vm: vm), isActive: $showingAddTransaction) { EmptyView() }
            
            // Group Detail
            content
        }
        .navigationTitle(vm.title)
        .alert("Edit Group Title", isPresented: $showingEditTitleAlert) {
            TextField("Group Title", text: $editedTitle)
            Button {
                withAnimation {
                    vm.updateTitle(editedTitle)
                }
            } label: {
                Text("Confirm")
            }
            Button {
                // Do not update
            } label: {
                Text("Cancel")
            }
        } message: {
            Text("Group title should have at least one character.")
        }
        .sheet(isPresented: $showingGroupShare) {
            ActivityViewController(activityItems: vm.getGroupShareActivities())
        }
        .toolbar { toolbarMenu }
    }
    
    private var content: some View {
        List {
            // Section with the pie chart
            Section {
                let moneyText = CurrencyManager.getText(for: vm.totalExpenses)
                GroupDetailChartView(centerText: moneyText)
            } header: {
                Text("Chart")
            }
            
            // Section with the list of users
            Section {
                ForEach(vm.users) { user in
                    GroupDetailUserView(color: .red, user: user, money: vm.getTotalExpensesForUser(by: user.id))
                }
                .onDelete { indexSet in
                    withAnimation {
                        vm.deleteUsers(at: indexSet)
                    }
                }
            } header: {
                Text("Users")
            }
            
            // Section with all transactions
            Section {
                ForEach(vm.transactions) { transaction in
                    GroupDetailTransactionView(transaction, selectedId: $selectedTransactionId)
                }
                .onDelete { indexSet in
                    withAnimation {
                        vm.deleteTransactions(at: indexSet)
                    }
                }
            } header: {
                Text("Transactions")
            }
        }
        .listStyle(.sidebar)
    }
    
    private var toolbarMenu: some View {
        Menu {
            Button {
                editedTitle = vm.title
                showingEditTitleAlert = true
            } label: {
                Label("Edit Title", systemImage: "square.and.pencil")
            }
            Button {
                showingAddUser = true
            } label: {
                Label("Add User", systemImage: "person.badge.plus")
            }
            Button {
                showingAddTransaction = true
            } label: {
                Label("Add Transaction", systemImage: "bag.badge.plus")
            }
            Button {
                showingGroupShare = true
            } label: {
                Label("Share Group", systemImage: "square.and.arrow.up")
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .resizable().scaledToFit()
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
        //
    }
}
