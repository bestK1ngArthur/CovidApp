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
            List(viewModel.covidData?.russianAreas ?? []) { area in
                VStack(alignment: .leading) {
                    Text(area.name).font(.headline)
                    Text("Заражены: \(area.allTimeStatistic.cases)")
                    Text("Вылечилось: \(area.allTimeStatistic.cured)")
                    Text("Умерло: \(area.allTimeStatistic.deaths)")
                }
            }
            .navigationBarTitle("Области")
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
