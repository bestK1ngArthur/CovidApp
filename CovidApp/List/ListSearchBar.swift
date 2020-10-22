//
//  ListSearchBar.swift
//  CovidApp
//
//  Created by Artem Belkov on 22.10.2020.
//

import SwiftUI

struct ListSearchBar: View {
    @Binding var text: String
 
    @State private var isEditing = false
 
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            TextField("Поиск", text: $text)
                .padding(8)
                .background(Color.secondaryBackground)

                .onTapGesture {
                    self.isEditing = true
                }
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Отмена")
                }
                .padding(.trailing, 8)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }

        }
        .background(Color.secondaryBackground)
        .cornerRadius(16)
    }
}
