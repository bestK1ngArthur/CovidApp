//
//  MainViewModel.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var covidData: CovidData?
    
    func loadData() {
        cancellation = CovidDataSource.shared.dataPublisher()
            .sink(receiveCompletion: { _ in},
                  receiveValue: { covidData in
                    DispatchQueue.main.async {
                        self.covidData = covidData
                    }
                  })
    }
    
    func cancel() {
        cancellation?.cancel()
    }

    private var cancellation: AnyCancellable?
}
