//
//  ListViewModel.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import Foundation
import Combine

class ListViewModel: ObservableObject {
    @Published var russianStates: [ListAreaViewModel] = []
    @Published var countries: [ListAreaViewModel] = []
    
    func loadData() {
        cancellation = CovidDataSource.shared.dataPublisher()
            .sink(receiveCompletion: { _ in},
                  receiveValue: { covidData in
                    DispatchQueue.main.async {
                        func mapAreas(_ areas: [Area]) -> [ListAreaViewModel] {
                            areas.map { area in
                                ListAreaViewModel(
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
