//
//  AuthView.swift
//  Expense Sharing
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
            AnimatedLogoView(sizeLimit: 80, isAnimating: true)
                .padding(.top, appManager.isKeyboardUp ? 6 : 24)
                .padding(.bottom, appManager.isKeyboardUp ? 6 : 12)
            
            authOption
                .padding(.horizontal, 36)
            
            Spacer()
            VStack(spacing: 8) {
                Button {
                    withAnimation { isLoading = true }
                    
                    vm.resetServerWithTestData { result in
                        withAnimation { isLoading = false }
                        switch result {
                        case .success:
                            alertTitle = "Success"
                            alertMessage = "Server reset done."
                        case .failure(let error):
                            alertTitle = "Error"
                            alertMessage = error.localizedDescription
                        }
                        showingAlert = true
                    }
                } label: {
                    Label("Reset Server", systemImage: "arrow.triangle.2.circlepath")
                }
                Text("Clears server database and sets it to data from selected file.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .coverWithLoader(isLoading, hint: vm.hint)
        .appBackgroundGradient()
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            self.userEmail = "john@example.com"
//            self.userEmail = "alex@example.com"
        }
        .simpleAlert(isPresented: $showingAlert, title: alertTitle, message: alertMessage)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: vm.allowedContentTypes,
            allowsMultipleSelection: vm.allowsMultipleSelection
        ) { result in
            switch vm.handleSelectingFile(result) {
            case .success(let data):
                break
            case .failure(let error):
                alertTitle = "Error"
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
    
    private var authOption: some View {
        VStack {
            Text("Authenticate")
                .font(.largeTitle)
            
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
        
        withAnimation { isLoading = true }
        if showRegister {
            vm.registerUser(name: userName, email: userEmail, completion: authHandler)
        } else {
            vm.loginUser(email: userEmail, completion: authHandler)
        }
    }
    
    private func authHandler(_ result: Result<String, Error>) -> Void {
        withAnimation { isLoading = false }
        
        switch result {
        case .success(let user):
            appManager.appState = .authorised(user)
            
        case .failure(let error):
            alertTitle = "Error"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}
