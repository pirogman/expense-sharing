//
//  CapsuleDivider.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct CapsuleDivider: View {
    var body: some View {
        Capsule()
            .fill()
            .frame(height: 2)
            .padding(.horizontal, 16)
    }
}
