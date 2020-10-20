//
//  ListView.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel = ListViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Section(
                        header: Text("Регионы России")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                    ) {
                        ForEach(viewModel.russianStates) { viewModel in
                            ListAreaView(viewModel: viewModel)
                        }
                    }
                    Section(
                        header: Text("Страны")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                    ) {
                        ForEach(viewModel.countries) { viewModel in
                            ListAreaView(viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationBarTitle("Статистика")
        }
        .onAppear {
            UIScrollView.appearance().backgroundColor = .primaryBackground
            viewModel.loadData()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
