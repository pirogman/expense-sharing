//
//  GroupAddUserView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 07.03.2023.
//

import SwiftUI

struct GroupAddUserView: View {
    @ObservedObject var vm: GroupDetailViewModel
    
    @State var searchText: String = ""
    
    var body: some View {
        List {
            Text("Searching for \(searchText)")
            ForEach(vm.users) { user in
                GroupDetailUserView(color: .blue, user: user, money: 0.0)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Add User")
    }
}
