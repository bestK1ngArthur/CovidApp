//
//  ContentView.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = MainViewModel()

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
                            MainAreaView(viewModel: viewModel)
                        }
                    }
                    Section(
                        header: Text("Страны")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                    ) {
                        ForEach(viewModel.countries) { viewModel in
                            MainAreaView(viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationBarTitle("Статистика")
            .navigationBarItems(
                trailing: NavigationLink(
                    destination: SettingsView(),
                    label: {
                        Image(systemName: "gearshape.fill")
                    })
            )
        }
        .onAppear {
            UIScrollView.appearance().backgroundColor = .primaryBackground
            viewModel.loadData()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
