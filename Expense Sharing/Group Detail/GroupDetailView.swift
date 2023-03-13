//
//  GroupDetailView.swift
//  Expense Sharing
//

import SwiftUI

struct GroupDetailView: View {
    @StateObject var vm: GroupDetailViewModel
    
    @State var showingEditTitleAlert = false
    @State var editedTitle = ""
    
    @State var showingAddUser = false
    @State var showingAddTransaction = false
    @State var showingGroupShare = false
    @State var showingReport = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var hideChartSection = false
    @State var hideUsersSection = false
    @State var hideTransactionsSection = false
    
    @State var selectedTransactionId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: vm.groupTitle, addBackButton: true) {
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
                Button {
                    showingReport = true
                } label: {
                    Label("Generate Report", systemImage: "arrow.left.arrow.right.square")
                }
            }
            .padding(.trailing, 16)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    chartSection
                    usersSection
                    transactionsSection
                }
                .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
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
        .fullScreenCover(
            isPresented: $showingReport,
            content: {
                GroupReportView(vm: vm)
            }
        )
    }
    
    private var chartSection: some View {
        VStack {
            HideOptionHeaderView(title: "Chart", hideContent: $hideChartSection)
                .padding(.horizontal, 16)
            
            let estimatedHeight: CGFloat? = vm.groupUsers.count < 6 ? nil : 180
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 4) {
                    let maxWidth = UIScreen.main.bounds.width / 2 - 32
                    let limits = vm.getUsersAmountsLimits()
                    HStack(spacing: 24) {
                        Text("Share part")
                            .frame(width: maxWidth, alignment: .trailing)
                        Text("Paid amount")
                            .frame(width: maxWidth, alignment: .leading)
                    }
                    .font(.caption)
                    .padding(.bottom, 6)
                    ForEach(vm.groupUsers) { user in
                        let amounts = vm.getUserAmounts(for: user)
                        let userShareWidth = maxWidth * (abs(amounts.1) / abs(limits.1))
                        let userPaidWidth = maxWidth * (abs(amounts.0) / abs(limits.0))
                        let barColor = vm.userColors[user.email] ?? .white
                        let textColor: Color = barColor == .white ? .blue : .white
                        let shareMoneyText = CurrencyManager.getText(for: amounts.1, currencyCode: vm.groupCurrencyCode)
                        let paidMoneyText = CurrencyManager.getText(for: amounts.0, currencyCode: vm.groupCurrencyCode)
                        TwoWayChartRowView(
                            barHeight: 30,
                            barColor: barColor,
                            leftWidth: userShareWidth,
                            rightWidth: userPaidWidth,
                            textColor: textColor,
                            leftText: shareMoneyText,
                            rightText: paidMoneyText,
                            putLeftTextOverBar: userShareWidth > maxWidth / 2,
                            putRightTextOverBar: userPaidWidth > maxWidth / 2
                        )
                            .font(.caption)
                    }
                }
                .padding(.vertical, 4)
                .overlay(alignment: .center) {
                    Capsule()
                        .fill()
                        .frame(width: 2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .frame(height: hideChartSection ? 0 : estimatedHeight)
        }
    }
    
    private var usersSection: some View {
        VStack {
            HideOptionHeaderView(title: "Users", hideContent: $hideUsersSection)
                .padding(.horizontal, 16)
            
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
                                let amounts = vm.getUserAmounts(for: user)
                                GroupDetailUserItemView(
                                    color: vm.userColors[user.email] ?? .white,
                                    userName: user.name,
                                    userEmail: user.email,
                                    amount: amounts.0 - abs(amounts.1),
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
                .padding(.horizontal, 16)
            
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
                                SwipeToRemoveItemView() {
                                    GroupDetailTransactionItemView(
                                        isSelected: transaction.id == selectedTransactionId,
                                        description: transaction.description,
                                        paidExpense: paid,
                                        otherExpenses: expenses,
                                        currencyCode: vm.groupCurrencyCode
                                    )
                                } onSelect: {
                                    withAnimation {
                                        if selectedTransactionId == transaction.id {
                                            selectedTransactionId = nil
                                        } else {
                                            selectedTransactionId = transaction.id
                                        }
                                    }
                                } onDelete: {
                                    withAnimation {
                                        vm.removeTransaction(transaction)
                                        vm.updateGroup()
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
