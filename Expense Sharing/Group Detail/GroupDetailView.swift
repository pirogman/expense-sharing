//
//  GroupDetailView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

struct GroupSectionHeader: View {
    let title: String
    @Binding var hideContent: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
            Spacer()
            Button {
                withAnimation {
                    hideContent.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .resizable().scaledToFit()
                    .squareFrame(side: 16)
                    .padding(4)
                    .rotationEffect(.degrees(hideContent ? -180 : 0))
                    .animation(.linear, value: hideContent)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct GroupDetailView: View {
    @StateObject var vm: GroupDetailViewModel
    
    @State var showingEditTitleAlert = false
    @State var editedTitle = ""
    
    @State var showingAddUser = false
    @State var showingAddTransaction = false
    @State var showingGroupShare = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var hideChartSection = false
    @State var hideUsersSection = false
    @State var hideTransactionsSection = false
    
    var body: some View {
        VStack {
            CustomNavigationBar(title: "Group", addBackButton: true) {
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
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    chartSection
                    usersSection
                    transactionsSection
                }
            }
        }
        .appBackgroundGradient()
        .navigationBarHidden(true)
        .textFieldAlert(isPresented: $showingEditTitleAlert, title: "Edit Title", message: "Group title consist of at least 1 character.", placeholder: "Title", input: $editedTitle) {
//            withAnimation {
//                switch vm.editTitle(editedTitle) {
//                case .success: break
//                case .failure(let error):
//                    alertTitle = "Error"
//                    alertMessage = error.localizedDescription
//                    showingAlert = true
//                }
//            }
        }
//        .sheet(isPresented: $showingGroupShare) {
//            ActivityViewController(activityItems: vm.getGroupShareActivities()) { _ in
//                vm.clearSharedUserFile()
//            }
//        }
//        .fullScreenCover(
//            isPresented: $showingAddUser,
//            onDismiss: { vm.updateUsers() },
//            content: { GroupAddUserView(vm: GroupAddUserViewModel(vm.group)) }
//        )
//        .fullScreenCover(
//            isPresented: $showingAddTransaction,
//            onDismiss: { vm.updateTransactions() },
//            content: { GroupAddTransactionView(vm: GroupAddTransactionViewModel(vm.group, payingUser: vm.user)) }
//        )
    }
    
    private var chartSection: some View {
        VStack {
            GroupSectionHeader(title: "Chart", hideContent: $hideChartSection)

            Circle()
                .strokeBorder(.red, lineWidth: 40)
                .squareFrame(side: 160)
                .padding()
                .frame(height: hideChartSection ? 0 : 180)
        }
    }
    
    private var usersSection: some View {
        VStack {
            GroupSectionHeader(title: "Users", hideContent: $hideUsersSection)
            
            let estimatedHeight: CGFloat? = vm.users.count < 6 ? nil : 300
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.users.isEmpty {
                        Text("No users.")
                    } else {
                        ForEach(vm.users) { user in
                            VStack(spacing: 0) {
                                if vm.users.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                GroupDetailUserView(
                                    color: .red,
                                    userName: user.name,
                                    userEmail: user.email,
                                    paidAmount: 150,
                                    owedAmount: -230,
                                    currencyCode: nil
                                )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.users.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .frame(height: hideUsersSection ? 0 : estimatedHeight)
        }
    }
    
    private var transactionsSection: some View {
        VStack {
            GroupSectionHeader(title: "Transactions", hideContent: $hideTransactionsSection)
            
            let estimatedHeight: CGFloat? = vm.users.count < 11 ? nil : 300
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.users.isEmpty {
                        Text("No users.")
                    } else {
                        ForEach(vm.users) { user in
                            VStack(spacing: 0) {
                                if vm.users.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                let isSelected = vm.users.first?.id == user.id
                                let expenses = vm.users.filter { $0.id != user.id }
                                    .map { ($0.email, $0.name, -25.9) }
                                GroupDetailTransactionView(
                                    isSelected: isSelected,
                                    description: nil,
                                    paidUserName: user.name,
                                    paidAmount: 100,
                                    currencyCode: nil,
                                    expenses: expenses
                                )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.users.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .frame(height: hideTransactionsSection ? 0 : estimatedHeight)
        }
    }
    
//    private var content: some View {
//        List {
//            // Section with the pie chart
//            Section {
//                let moneyText = CurrencyManager.getText(for: vm.totalExpenses)
//                GroupDetailChartView(centerText: moneyText)
//            } header: {
//                Text("Chart")
//            }
//
//            // Section with the list of users
//            Section {
//                ForEach(vm.users) { user in
//                    GroupDetailUserView(color: .red, user: user, money: vm.getTotalExpensesForUser(by: user.id))
//                }
//                .onDelete { indexSet in
//                    withAnimation {
//                        vm.deleteUsers(at: indexSet)
//                    }
//                }
//            } header: {
//                Text("Users")
//            }
//
//            // Section with all transactions
//            Section {
//                ForEach(vm.transactions) { transaction in
//                    GroupDetailTransactionView(transaction, selectedId: $selectedTransactionId)
//                }
//                .onDelete { indexSet in
//                    withAnimation {
//                        vm.deleteTransactions(at: indexSet)
//                    }
//                }
//            } header: {
//                Text("Transactions")
//            }
//        }
//        .listStyle(.sidebar)
//    }
}
