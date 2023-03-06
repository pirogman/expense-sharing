//
//  ContentView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 06.03.2023.
//

import SwiftUI

struct GroupListItemView: View {
    let group: GroupWithUsers
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.title)
                    .font(.headline)
                Text("\(group.users.count) user(s)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .lineLimit(1)
    }
}

struct UserListItemView: View {
    let user: User
    
    var body: some View {
        HStack {
            Text(user.name)
            Text("(\(user.email))")
                .foregroundColor(.gray)
        }
        .lineLimit(1)
    }
}

struct ContentView: View {
    @State var data: LocalData?
    
    var body: some View {
        NavigationView {
            List(data?.groups ?? []) { group in
                NavigationLink {
                    List(group.users) { user in
                        UserListItemView(user: user)
                    }
                    .navigationTitle(group.title)
                } label: {
                    GroupListItemView(group: group)
                }
            }
            .navigationTitle("Groups")
            .onAppear {
                self.data = JSONManager.loadTestData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
