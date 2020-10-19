//
//  MainViewModel.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var russianStates: [MainAreaViewModel] = []
    @Published var countries: [MainAreaViewModel] = []
    
    func loadData() {
        cancellation = CovidDataSource.shared.dataPublisher()
            .sink(receiveCompletion: { _ in},
                  receiveValue: { covidData in
                    DispatchQueue.main.async {
                        func mapAreas(_ areas: [Area]) -> [MainAreaViewModel] {
                            areas.map { area in
                                MainAreaViewModel(
                                    code: area.code,
                                    kind: area.kind,
                                    name: area.name,
                                    statistic: area.dailyStatistic
                                )
                            }
                        }
                        
                        self.russianStates = mapAreas(covidData.russianStates)
                        self.countries = mapAreas(covidData.countries)
                    }
                  })
    }
    
    func cancel() {
        cancellation?.cancel()
    }

    private var cancellation: AnyCancellable?
}
