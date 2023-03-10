//
//  AppManager.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 10.03.2023.
//

import SwiftUI
import Combine

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
    private var cancellableSet = Set<AnyCancellable>()
    
    @Published var appState = AppState.unauthorised
    @Published var isKeyboardUp = false
    
    init() {
        Publishers.Merge(
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] up in
                self?.isKeyboardUp = up
            }
            .store(in: &cancellableSet)
    }
}
