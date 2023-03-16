//
//  GroupAddTransactionView.swift
//  Expense Sharing
//

import SwiftUI

struct GroupAddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var appManager: AppManager
    
    @StateObject var vm: GroupAddTransactionViewModel
    
    @State var isLoading = false
    
    enum Field: Hashable {
        case paidAmountField
        case selectedAmountField
    }
    
    @FocusState private var focusedField: Field?
    @State private var amount = ""
    
    @State var selectedUser: FIRUser?
    @State var selectedUserAmount = ""
    @State var showingSelectedUserAlert = false
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            navigationBar
            amountSection
            CapsuleDivider()
            usersSection
        }
        .appBackgroundGradient()
        .coverWithLoader(isLoading, hint: vm.hint)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            amount = CurrencyManager.getText(for: 0, currencyCode: vm.currencyCode)
        }
        .alert("Set Expense", isPresented: $showingSelectedUserAlert) {
            TextField("Amount", text: $selectedUserAmount)
                .focused($focusedField, equals: .selectedAmountField)
                .keyboardType(.decimalPad)
            Button {
                guard let user = selectedUser else { return }
                let money = CurrencyManager.getNumber(from: selectedUserAmount)
                switch vm.setExpense(money, on: user) {
                case .success: break
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            } label: {
                Text("Confirm")
            }
            Button {
                selectedUser = nil
                selectedUserAmount = ""
                focusedField = nil
            } label: {
                Text("Cancel")
            }
        } message: {
            let name = selectedUser?.name ?? "selected user"
            let maxAmount = CurrencyManager.getText(for: vm.remainingExpenseAmount, currencyCode: vm.currencyCode)
            Text("Enter expense for \(name). Provide amount up to \(maxAmount) or change other users expenses first.")
        }
        .simpleAlert(isPresented: $showingAlert, title: alertTitle, message: alertMessage)
        .onChange(of: focusedField) { newValue in
            if newValue == nil {
                // Provide currency formatting on deselecting amount field
                let money = CurrencyManager.getNumber(from: amount)
                vm.paidAmount = money > 0 ? money : 0
                amount = CurrencyManager.getText(for: vm.paidAmount, currencyCode: vm.currencyCode)
            } else if newValue == .paidAmountField {
                // Clear amount field when no or too small number
                if vm.paidAmount <= 0.01 {
                    amount = ""
                }
            }
        }
        .onChange(of: vm.paidAmount) { newValue in
            // Reset split when paid amount changed
            withAnimation { vm.resetSplit() }
        }
    }
    
    private var navigationBar: some View {
        AddOptionNavigationBar(
            title: "Add Transaction",
            cancelAction: {
                presentationMode.wrappedValue.dismiss()
            },
            confirmAction: {
                withAnimation { isLoading = true }
                vm.addTransaction { result in
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
    
    private var amountSection: some View {
        VStack(alignment: .leading) {
            Text(vm.groupTitle)
                .font(.title)
            
            TextField("Amount", text: $amount)
                .focused($focusedField, equals: .paidAmountField)
                .keyboardType(.decimalPad)
                .stylishTextField()
            Text("Enter the amount you paid.")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            
            TextEditor(text: $vm.description)
                .foregroundColor(.gradientDark)
                .accentColor(.gradientLight)
                .tint(.gradientLight)
                .frame(height: 60)
                .padding(.horizontal, 4)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                )
                .onSubmit {
                    hideKeyboard()
                }
            Text("Enter a short description up to 120 characters.")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            
            HStack {
                Button {
                    withAnimation { vm.splitEvenly() }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white, lineWidth: 1.5)
                        .overlay(
                            Text("SPLIT EVENLY")
                                .font(.headline)
                        )
                }
                .frame(height: 40)
                Button {
                    withAnimation { vm.resetSplit() }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white, lineWidth: 1.5)
                        .overlay(
                            Text("RESET SPLIT")
                                .font(.headline)
                        )
                }
                .frame(height: 40)
            }
            Text("Split expenses between other users.")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }
    
    private var usersSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Other Users").font(.title)
                Spacer()
            }
            .padding(.horizontal, 32)
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    if vm.otherUsers.isEmpty {
                        Text("You are the only one in the group.")
                    } else {
                        ForEach(vm.otherUsers) { user in
                            VStack(spacing: 0) {
                                if vm.otherUsers.first?.id != user.id {
                                    Capsule()
                                        .fill(.white)
                                        .frame(height: 1)
                                }
                                UserAmountItemView(userName: user.name,
                                                   userEmail: user.email,
                                                   amount: vm.otherUsersExpenses[user.id]!,
                                                   currencyCode: vm.currencyCode)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if vm.paidAmount < 0.01 {
                                            alertTitle = "Error"
                                            alertMessage = "Please, enter paid amount first."
                                            showingAlert = true
                                            return
                                        }
                                        
                                        selectedUser = user
                                        let money = vm.otherUsersExpenses[user.id]!
                                        if money <= 0.01 {
                                            selectedUserAmount = ""
                                        } else {
                                            selectedUserAmount = CurrencyManager.getText(for: money, currencyCode: vm.currencyCode)
                                        }
                                        showingSelectedUserAlert = true
                                    }
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(vm.otherUsers.isEmpty ? .clear : .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .maskScrollEdges(startPoint: .top, endPoint: .bottom)
            .animation(.default, value: vm.otherUsers.count)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
