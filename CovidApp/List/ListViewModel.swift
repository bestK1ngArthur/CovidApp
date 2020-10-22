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
    @Published var searchText: String = ""
    
    init() {
        let loadList = CovidDataSource.shared.dataPublisher()
            .sink(receiveCompletion: { _ in },
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
                        
                        self.allRussianStates = mapAreas(covidData.russianStates)
                        self.allCountries = mapAreas(covidData.countries)
                        
                        self.russianStates = self.allRussianStates
                        self.countries = self.allCountries
                    }
                  })
        
        bag.insert(loadList)
        
        let filterList = $searchText.sink { [unowned self] searchText in
            guard searchText.isNotEmpty else {
                self.russianStates = self.allRussianStates
                self.countries = self.allCountries
                
                return
            }
            
            self.russianStates = self.allRussianStates.filter { $0.name.contains(searchText) }
            self.countries = self.allCountries.filter { $0.name.contains(searchText) }
        }
        
        bag.insert(filterList)
    }
    
    private var allRussianStates: [ListAreaViewModel] = []
    private var allCountries: [ListAreaViewModel] = []

    private var bag: Set<AnyCancellable> = []
}
