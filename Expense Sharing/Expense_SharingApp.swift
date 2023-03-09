//
//  Expense_SharingApp.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

enum AppState {
    case unauthorised
    case authorised(User)
}

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorised, .unauthorised):
            return true
        case (let .authorised(user1), let .authorised(user2)):
            return user1.id == user2.id
        default:
            return false
        }
    }
}

class AppManager: ObservableObject {
    static let shared = AppManager()
    private init() { }
    
    @Published var appState = AppState.unauthorised
}

@main
struct Expense_SharingApp: App {
    @ObservedObject var appManager = AppManager.shared
        
    init() {
        // Provide global setup if needed
    }
    
    var body: some Scene {
        WindowGroup {
            SwiftUI.Group {
                switch appManager.appState {
                case .unauthorised:
                    AuthView()
                        .transition(.move(edge: .leading))
                case .authorised(let user):
                    UserProfileView(user: user)
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut, value: appManager.appState)
        }
    }
}

// MARK: -

extension Optional where Wrapped == String {
    var hasText: Bool { self?.isEmpty == false }
}

extension Color {
    static let gradientLight = Color("gradientLight")
    static let gradientDark = Color("gradientDark")
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

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
    func appBackgroundGradient() -> some View {
        self.preferredColorScheme(.light)
            .foregroundColor(.accentColor)
            .tint(.accentColor)
            .background(
                LinearGradient(gradient: Gradient(colors: [.gradientLight, .gradientDark]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
}

extension View {
    func simpleAlert(isPresented: Binding<Bool>, title: String, message: String) -> some View {
        self.alert(title, isPresented: isPresented) {
                Button {
                    // Do nothing
                } label: {
                    Text("OK")
                }
            } message: {
                Text(message)
            }
    }
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
