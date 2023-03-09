//
//  AuthView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct AuthView: View {
    @StateObject var vm = AuthViewModel()
    
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
                .padding(.top, focusedField == nil ? 24 : 6)
                .padding(.bottom, focusedField == nil ? 12 : 6)
            
            authOption
                .padding(.horizontal, 36)
            
            Spacer()
            Button {
                showingFilePicker = true
            } label: {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .appBackgroundGradient()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
#if DEBUG
            userEmail = "alex@example.com"
            DBManager.shared.loadTestData()
#endif
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
            showingAlert = true
        }
    }
    
    private var authOption: some View {
        VStack {
            Text("Authenticate")
                .font(.largeTitle)
            let counts = vm.getDBCounts()
            Text("\(counts.0) Users | \(counts.1) Groups")
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
                        Text(" Should contain at least 3 characters.")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 4)
                    }
                }
                VStack(alignment: .leading) {
                    TextField("email@example.com", text: $userEmail)
                        .focused($focusedField, equals: .emailField)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
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
            .frame(height: focusedField == nil ? 200 : 160)
            
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
            AppManager.shared.appState = .authorised(user)
            
        case .failure(let error):
            alertTitle = "Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}
