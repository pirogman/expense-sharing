//
//  SearchOptionHeaderView.swift
//  Expense Sharing
//
//  Created by Alex Pirog on 12.03.2023.
//

import SwiftUI

struct SearchOptionHeaderView: View {
    let title: String
    let searchPrompt: String
    let searchHint: String?
    
    @Binding var showingSearch: Bool
    @Binding var searchText: String
    
    init(title: String, searchPrompt: String = "Search...", searchHint: String? = nil, showingSearch: Binding<Bool>, searchText: Binding<String>) {
        self.title = title
        self.searchPrompt = searchPrompt
        self.searchHint = searchHint
        self._showingSearch = showingSearch
        self._searchText = searchText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.title)
                Spacer()
                Button {
                    withAnimation {
                        showingSearch.toggle()
                        searchText = ""
                    }
                } label: {
                    Image(systemName: showingSearch ? "xmark" : "magnifyingglass")
                        .resizable().scaledToFit()
                        .squareFrame(side: showingSearch ? 12 : 18)
                        .padding(showingSearch ? 6 : 3)
                }
            }
            
            if showingSearch {
                TextField(searchPrompt, text: $searchText)
                    .textContentType(.name)
                    .stylishTextField()
                    .onSubmit {
                        hideKeyboard()
                    }
                    .padding(.bottom, searchHint == nil ? 4 : 0)
                
                if let hint = searchHint {
                    Text(hint)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                }
            }
        }
    }
}
