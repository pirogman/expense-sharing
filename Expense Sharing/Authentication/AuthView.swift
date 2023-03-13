//
//  AuthView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appManager: AppManager
    
    @StateObject var vm = AuthViewModel()
    
    @State var isLoading = false
    
    enum Field: Hashable {
        case nameField
        case emailField
    }
    
    @FocusState private var focusedField: Field?
    @State var showRegister = false
    @State var userName = ""
    @State var userEmail = ""
    
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    @State var showingFilePicker = false
    
    var body: some View {
        VStack {
            AnimatedLogoView(sizeLimit: 80)
                .padding(.top, appManager.isKeyboardUp ? 6 : 24)
                .padding(.bottom, appManager.isKeyboardUp ? 6 : 12)
            
            authOption
                .padding(.horizontal, 36)
            
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                Button {
                    showingFilePicker = true
                } label: {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                }
                Spacer()
                Button {
                    syncFromServer()
                } label: {
                    Label("Sync Data", systemImage: "arrow.triangle.2.circlepath")
                }
                Spacer()
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .coverWithLoader(isLoading)
        .appBackgroundGradient()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            vm.updateDBCounts()
        }
        .simpleAlert(isPresented: $showingAlert, title: alertTitle, message: alertMessage)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: vm.allowedContentTypes,
            allowsMultipleSelection: vm.allowsMultipleSelection
        ) { result in
            switch vm.handleSelectingFile(result) {
            case .success((let usersCount, let groupsCount)):
                alertTitle = "Success"
                alertMessage = "Successfully imported \(usersCount) users and \(groupsCount) groups from the given file."
            case .failure(let error):
                alertTitle = "Error"
                alertMessage = error.localizedDescription
            }
            vm.updateDBCounts()
            showingAlert = true
        }
    }
    
    private var authOption: some View {
        VStack {
            Text("Authenticate")
                .font(.largeTitle)
            Text("\(vm.usersCount) Users | \(vm.groupsCount) Groups")
                .font(.caption)
            
            VStack {
                if showRegister {
                    VStack(alignment: .leading) {
                        TextField("Name", text: $userName)
                            .focused($focusedField, equals: .nameField)
                            .textContentType(.name)
                            .stylishTextField()
                            .onSubmit {
                                focusedField = .emailField
                            }
                        Text("Should contain at least 3 characters.")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                    }
                }
                VStack(alignment: .leading) {
                    TextField("email@example.com", text: $userEmail)
                        .focused($focusedField, equals: .emailField)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .stylishTextField()
                        .onSubmit {
                            focusedField = nil
                            onAuthAction()
                        }
                    Text(showRegister
                         ? " Should be a proper email address."
                         : " Should be already in the database.")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                }
            }
            .frame(height:  appManager.isKeyboardUp ? 160 : 200)
            
            HStack {
                Button {
                    if showRegister {
                        onAuthAction()
                    } else {
                        withAnimation {
                            showRegister = true
                        }
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white, lineWidth: showRegister ? 1.5 : 1)
                        .overlay(
                            Text("REGISTER")
                                .font(showRegister ? .headline : .footnote)
                        )
                }
                .frame(width: showRegister ? 160 : 90, height: showRegister ? 40 : 32)
                
                Button {
                    if !showRegister {
                        onAuthAction()
                    } else {
                        withAnimation {
                            showRegister = false
                        }
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.white, lineWidth: !showRegister ? 1.5 : 1)
                        .overlay(
                            Text("LOGIN")
                                .font(!showRegister ? .headline : .footnote)
                        )
                }
                .frame(width: !showRegister ? 160 : 90, height: !showRegister ? 40 : 32)
            }
        }
    }
    
    private func onAuthAction() {
        focusedField = nil
        
        let result = showRegister
        ? vm.registerUser(name: userName, email: userEmail)
        : vm.loginUser(email: userEmail)
        
        switch result {
        case .success(let user):
            appManager.appState = .authorised(user)
            
        case .failure(let error):
            alertTitle = "Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func syncFromServer() {
        withAnimation {
            isLoading = true
            FRDManager.shared.syncFromServer { result in
                vm.updateDBCounts()
                isLoading = false
                switch result {
                case .success:
                    alertTitle = "Success"
                    alertMessage = "You synched with the server."
                    showingAlert = true
                case .failure(let error):
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}
