//
//  UserProfileView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 08.03.2023.
//

import SwiftUI

struct GroupListItemView: View {
    let group: Group
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(group.title)
                    .font(.headline)
                Text("\(group.users.count) user(s)")
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .resizable().scaledToFit()
                .squareFrame(side: 12)
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.white)
        )
    }
}

struct UserProfileView: View {
    @StateObject var vm: UserProfileViewModel
    
    init(user: User) {
        self._vm = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                userInfo
                    .padding(.horizontal, 32)
                
                Capsule()
                    .fill(Color.white)
                    .frame(height: 2)
                    .padding(.horizontal, 16)
                    .padding(.vertical)
                
                userGroups
                    .padding(.horizontal, 32)
            }
            .backgroundGradient()
            .foregroundColor(.white)
            .navigationBarHidden(true)
        }
    }
    
    private var userInfo: some View {
        VStack {
            HStack {
                Text("Profile")
                    .font(.largeTitle)
                Spacer()
                Menu {
                    Button {
                        //
                    } label: {
                        Label("Edit Name", systemImage: "square.and.pencil")
                    }
                    Button {
                        //
                    } label: {
                        Label("Add Group", systemImage: "note.text.badge.plus")
                    }
                    Button {
                        //
                    } label: {
                        Label("Share User", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        AppManager.shared.appState = .unauthorised
                    } label: {
                        Label("Leave", systemImage: "arrow.backward.square")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable().scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(vm.user.name)
                        .font(.headline)
                    Text(vm.user.email)
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding(.vertical)
        }
    }
    
    private var userGroups: some View {
        VStack {
            HStack {
                Text("Groups")
                    .font(.title)
                Spacer()
                Button {
                    // Search
                } label: {
                    Image(systemName: "magnifyingglass")
                        .resizable().scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(3)
                }
            }
            ScrollView(.vertical, showsIndicators: true) {
                if vm.groups.isEmpty {
                    Text("No groups yet.")
                } else {
                    ForEach(vm.groups) { group in
                        NavigationLink {
                            GroupDetailView(vm.getManagedGroup(from: group))
                        } label: {
                            GroupListItemView(group: group)
                        }
                    }
                }
            }
        }
    }
}
