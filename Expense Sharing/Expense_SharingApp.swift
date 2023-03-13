//
//  Expense_SharingApp.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
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
        }
    }
}
