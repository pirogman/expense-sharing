//
//  InitialSyncView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct InitialSyncView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.5)
                Spacer()
            }
            Text("Synchronising...")
                .padding()
            Spacer()
        }
        .backgroundGradient()
        .foregroundColor(.white)
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
