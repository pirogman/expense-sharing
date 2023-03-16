//
//  AppManager.swift
//  Expense Sharing
//

import SwiftUI
import Combine

enum AppState {
    case unauthorised
    case authorised(String) // user id
}

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorised, .unauthorised):
            return true
        case (let .authorised(id1), let .authorised(id2)):
            return id1 == id2
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
