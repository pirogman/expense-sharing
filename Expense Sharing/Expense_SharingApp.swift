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
    
    init() {
//        UITableView.appearance().backgroundColor = UIColor.clear
//        UITableViewCell.appearance().backgroundColor = UIColor.clear
    }
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                switch appManager.appState {
                case .initialSync:
                    InitialSyncView()
                case .unauthorised:
                    AuthView()
                case .authorised(let user):
                    UserProfileView(user: user)
                }
            }
            .preferredColorScheme(.light)
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

extension View {
    func backgroundGradient() -> some View {
        self.background(
            LinearGradient(gradient: Gradient(colors: [.cyan, .blue]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}

extension View {
    func textFieldAlert(isPresented: Binding<Bool>, title: String, message: String, placeholder: String, input: Binding<String>, onConfirm: @escaping () -> Void) -> some View {
        self.alert(title, isPresented: isPresented) {
                TextField(placeholder, text: input)
                Button {
                    onConfirm()
                } label: {
                    Text("Confirm")
                }
                Button {
                    // Do not update
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text(message)
            }
    }
}
