//
//  GroupAddTransactionView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 07.03.2023.
//

import SwiftUI

struct GroupAddTransactionView: View {
    @ObservedObject var vm: GroupDetailViewModel
    
    @State var searchText: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            Text("Searching for \(searchText)")
            Spacer()
        }
        .searchable(text: $searchText)
        .navigationTitle("Add Transaction")
    }
}
