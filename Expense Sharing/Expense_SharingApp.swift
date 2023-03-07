//
//  Expense_SharingApp.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

enum AppState {
    case initialSync
    case unauthorised
    case authorised(User)
}

class AppManager: ObservableObject {
    static let shared = AppManager()
    private init() { }
    
    @Published var appState = AppState.initialSync
}

@main
struct Expense_SharingApp: App {
    @ObservedObject var appManager = AppManager.shared
    
    var body: some Scene {
        WindowGroup {
            switch appManager.appState {
            case .initialSync:
                InitialSyncView()
            case .unauthorised:
                AuthView()
            case .authorised(let user):
                GroupsListView(user: user)
            }
        }
    }
}

struct InitialSyncView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .padding()
            Text("Synchronising...")
            Spacer()
        }
        .foregroundColor(.gray)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                let testData = JSONManager.loadTestData()
                DBManager.shared.importData(testData)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    AppManager.shared.appState = .unauthorised
                }
            }
        }
    }
}

import UniformTypeIdentifiers

enum AuthError: Error, LocalizedError {
    case invalidEmail, invalidName
    case alreadyRegistered, notRegistered
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Failed to authenticate. Invalid email."
        case .invalidName: return "Failed to authenticate. Invalid name."
        case .alreadyRegistered: return "Failed to authenticate. Already registered."
        case .notRegistered: return "Failed to authenticate. Not registered yet."
        }
    }
}

class AuthViewModel: ObservableObject {
    func getDBCounts() -> (Int, Int) {
        return (DBManager.shared.users.count, DBManager.shared.groups.count)
    }
    
    func registerUser(name: String, email: String) -> Result<User, Error> {
        guard let validName = Validator.validateUserName(name) else {
            return .failure(AuthError.invalidName)
        }
        guard let validEmail = Validator.validateEmail(email) else {
            return .failure(AuthError.invalidEmail)
        }
        if let user = DBManager.shared.addUser(name: validName, email: validEmail) {
            return .success(user)
        }
        return .failure(AuthError.alreadyRegistered)
    }
    
    func loginUser(email: String) -> Result<User, Error> {
        guard let validEmail = Validator.validateEmail(email) else {
            return .failure(AuthError.invalidEmail)
        }
        guard let user = DBManager.shared.getUser(by: validEmail) else {
            return .failure(AuthError.notRegistered)
        }
        return .success(user)
    }
    
    let allowedContentTypes = [UTType.json]
    let allowsMultipleSelection = false
    
    func handleSelectingFile(_ result: Result<[URL], Error>) -> Result<(Int, Int), Error> {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    let data = JSONManager.loadFromUrl(url)
                    DBManager.shared.importData(data)
                    return .success((data.users.count, data.groups.count))
                }
            }
            return .failure(URLError.cannotOpenFile as! Error)
        case .failure(let error):
            return .failure(error)
        }
    }
}

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
            authOption
                .padding(.horizontal, 36)
                .padding(.top, 60)
            Spacer()
            Button {
                showingFilePicker = true
            } label: {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
            .padding(.bottom)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button {
                // Do nothing
            } label: {
                Text("OK")
            }
        } message: {
            Text(alertMessage)
        }
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
                .foregroundColor(.gray)
            
            VStack {
                if showRegister {
                    VStack(alignment: .leading) {
                        TextField("name", text: $userName)
                            .focused($focusedField, equals: .nameField)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                            .onSubmit {
                                focusedField = .emailField
                            }
                        Text("User name should contain at least 3 characters.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom)
                    }
                }
                TextField("email@example.com", text: $userEmail)
                    .focused($focusedField, equals: .emailField)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .onSubmit {
                        onAuthAction()
                    }
            }
            .frame(height: 180)
            
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
                    Capsule()
                        .foregroundColor(.green)
                        .overlay(
                            Text("REGISTER")
                                .font(showRegister ? .headline : .footnote)
                        )
                        .foregroundColor(.white)
                }
                .frame(width: showRegister ? 160 : 90, height: showRegister ? 48 : 32)
                Button {
                    if !showRegister {
                        onAuthAction()
                    } else {
                        withAnimation {
                            showRegister = false
                        }
                    }
                } label: {
                    Capsule()
                        .foregroundColor(.blue)
                        .overlay(
                            Text("LOGIN")
                                .font(!showRegister ? .headline : .footnote)
                        )
                        .foregroundColor(.white)
                }
                .frame(width: !showRegister ? 160 : 90, height: !showRegister ? 48 : 32)
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

struct GroupListItemView: View {
    let group: Group
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.title)
                    .font(.headline)
                Text("\(group.users.count) user(s)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .lineLimit(1)
    }
}

class GroupListViewModel: ObservableObject {
    let user: User
    
    @Published var groups = [Group]()
    
    init(user: User) {
        self.user = user
        
        groups = DBManager.shared.getGroups(for: user)
    }
    
    func getManagedGroup(from group: Group) -> ManagedGroup {
        let users: [ManagedUser] = group.users.map { email in
            if let user = DBManager.shared.getUser(by: email) {
                return ManagedUser(name: user.name, email: user.email)
            }
            return ManagedUser(unknownUserEmail: email)
        }
        let transactions: [ManagedTransaction] = group.transactions.map { transaction in
            let expenses: [Expense] = transaction.expenses.keys
                .map { key in
                    let user = users.first(where: { $0.email == key }) ?? ManagedUser(unknownUserEmail: key)
                    let money = transaction.expenses[key]!
                    return Expense(user, money)
                }
                .sorted(by: { abs($0.money) > abs($1.money) })
            return ManagedTransaction(id: transaction.id, expenses: expenses, description: transaction.description)
        }
        return ManagedGroup(id: group.id, title: group.title, users: users, transactions: transactions)
    }
}

struct GroupsListView: View {
    @StateObject var vm: GroupListViewModel
    
    init(user: User) {
        self._vm = StateObject(wrappedValue: GroupListViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.groups.isEmpty {
                    Text("No groups yet")
                } else {
                    List(vm.groups) { group in
                        NavigationLink {
                            GroupDetailView(vm.getManagedGroup(from: group))
                        } label: {
                            GroupListItemView(group: group)
                        }
                    }
                }
            }
            .navigationTitle(vm.user.name)
        }
    }
}

// MARK: -

struct SquareFrameModifier: ViewModifier {
    let side: CGFloat
    
    func body(content: Content) -> some View {
        content.frame(width: side, height: side)
    }
}

extension View {
    func squareFrame(side: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: SquareFrameModifier(side: side))
    }
}
