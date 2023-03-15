//
//  Expense_SharingApp.swift
//  Expense Sharing
//

import SwiftUI

@main
struct Expense_SharingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var appManager = AppManager()
        
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
                    UserProfileView(vm: UserProfileViewModel(user))
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut, value: appManager.appState)
            .environmentObject(appManager)
            // Set everything to white by default as we would have
            // cyan-blue gradient as a background in all screens
            .tint(.white)
            .accentColor(.white)
            .foregroundColor(.white)
        }
    }
}
