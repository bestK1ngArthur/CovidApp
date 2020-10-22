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
                    ListSearchBar(text: $viewModel.searchText)
                        .padding(.horizontal, 16)
                    
                    if viewModel.russianStates.isNotEmpty {
                        Section(
                            header: Text("Регионы России")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                        ) {
                            ForEach(viewModel.russianStates) { viewModel in
                                ListAreaView(viewModel: viewModel)
                            }
                        }
                    }
                    
                    if viewModel.countries.isNotEmpty {
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
            }
            .navigationBarTitle("Статистика")
        }
        .onAppear {
            UIScrollView.appearance().backgroundColor = .primaryBackground
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
