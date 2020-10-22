//
//  AreaSectionView.swift
//  CovidApp
//
//  Created by Artem Belkov on 22.10.2020.
//

import SwiftUI

struct AreaSectionView<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        Text(title)
            .padding(.top, 16)
            .font(.headline)
        content
    }
}

struct AreaSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AreaSectionView("Секция") {
            EmptyView()
        }
    }
}
