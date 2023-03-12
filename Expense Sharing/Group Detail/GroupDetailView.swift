//
//  GroupDetailView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

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
    
    @State var selectedTransactionId: String?
    
    var body: some View {
        VStack {
            CustomNavigationBar(title: "Group", addBackButton: true) {
                Button {
                    editedTitle = vm.groupTitle
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
            withAnimation {
                switch vm.editTitle(editedTitle) {
                case .success: break
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
        .sheet(isPresented: $showingGroupShare) {
            ActivityViewController(activityItems: vm.getGroupShareActivities()) { _ in
                vm.clearSharedGroupFile()
            }
        }
        .fullScreenCover(
            isPresented: $showingAddUser,
            onDismiss: { vm.updateGroup() },
            content: {
                let vm = GroupAddUserViewModel(groupId: vm.groupId)
                GroupAddUserView(vm: vm)
            }
        )
        .fullScreenCover(
            isPresented: $showingAddTransaction,
            onDismiss: { vm.updateGroup() },
            content: {
                let vm = GroupAddTransactionViewModel(groupId: vm.groupId, payingUserEmail: vm.userEmail)
                GroupAddTransactionView(vm: vm)
            }
        )
    }
    
    private var chartSection: some View {
        VStack {
            HideOptionHeaderView(title: "Chart", hideContent: $hideChartSection)

            Circle()
                .strokeBorder(.red, lineWidth: 40)
                .squareFrame(side: 160)
                .padding()
                .frame(height: hideChartSection ? 0 : 180)
        }
    }
    
    private var usersSection: some View {
        VStack {
            HideOptionHeaderView(title: "Users", hideContent: $hideUsersSection)
            
            let estimatedHeight: CGFloat? = vm.groupUsers.count < 6 ? nil : 300
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.groupUsers.isEmpty {
                        Text("No users.")
                    } else {
                        ForEach(vm.groupUsers) { user in
                            VStack(spacing: 0) {
                                if vm.groupUsers.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                let amounts = vm.calculateUserAmounts(for: user)
                                GroupDetailUserItemView(
                                    color: vm.userColors[user.email] ?? .white,
                                    userName: user.name,
                                    userEmail: user.email,
                                    paidAmount: amounts.0,
                                    owedAmount: amounts.1,
                                    currencyCode: vm.groupCurrencyCode
                                )
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.groupUsers.isEmpty ? .clear : .white)
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
            HideOptionHeaderView(title: "Transactions", hideContent: $hideTransactionsSection)
            
            let estimatedHeight: CGFloat? = vm.groupTransactions.count < 11 ? nil : 600
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.groupTransactions.isEmpty {
                        Text("No transactions.")
                    } else {
                        ForEach(vm.groupTransactions) { transaction in
                            VStack(spacing: 0) {
                                if vm.groupTransactions.first?.id != transaction.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                var expenses = vm.getTransactionExpenses(transaction)
                                let paid = expenses.removeFirst()
                                GroupDetailTransactionItemView(
                                    isSelected: transaction.id == selectedTransactionId,
                                    description: transaction.description,
                                    paidExpense: paid,
                                    otherExpenses: expenses,
                                    currencyCode: vm.groupCurrencyCode
                                )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            if selectedTransactionId == transaction.id {
                                                selectedTransactionId = nil
                                            } else {
                                                selectedTransactionId = transaction.id
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
                        .strokeBorder(vm.groupTransactions.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .frame(height: hideTransactionsSection ? 0 : estimatedHeight)
        }
    }
}
