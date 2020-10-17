//
//  CovidProvider.swift
//  CovidWidgetExtension
//
//  Created by Artem Belkov on 17.10.2020.
//

import WidgetKit
import Combine

class CovidProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CovidEntry {
        return .placeholder
    }

    func getSnapshot(for configuration: CovidConfigurationIntent, in context: Context, completion: @escaping (CovidEntry) -> ()) {
        guard let request = request(from: configuration) else { return }
        
        loadEntry(for: request, configuration: configuration) { entry in
            completion(entry)
        }
        
        completion(.placeholder)
    }

    func getTimeline(for configuration: CovidConfigurationIntent, in context: Context, completion: @escaping (Timeline<CovidEntry>) -> ()) {
        guard let request = request(from: configuration) else { return }
        
        loadEntry(for: request, configuration: configuration) { entry in
            guard let updateDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) else {
                return
            }

            let timeline = Timeline(entries: [entry], policy: .after(updateDate))

            completion(timeline)
        }
    }
    
    private var cancellation: AnyCancellable?

    private func request(from configuration: CovidConfigurationIntent) -> AreaRequest? {
        guard let code = configuration.area?.identifier,
              let isCountry = configuration.area?.isCountry?.boolValue else {
            return nil
        }
        
        let request = AreaRequest(
            code: code,
            kind: isCountry ? .country : .russianState
        )
        
        return request
    }
    
    private func loadEntry(for request: AreaRequest,
                           configuration: CovidConfigurationIntent,
                           completion: @escaping (CovidEntry) -> Void) {
        if cancellation != nil {
            cancellation?.cancel()
        }

        cancellation = CovidDataSource.shared.areaDataPublisher(request)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { area in
                    var statistic: Statistic {
                        switch configuration.statisticType {
                        case .daily, .unknown: return area.dailyStatistic
                        case .allTime: return area.allTimeStatistic
                        }
                    }
                    
                    let entry = CovidEntry(
                        date: .now,
                        areaName: area.name,
                        statistic: statistic,
                        configuration: configuration
                    )
                    
                    completion(entry)
                  })
    }
}

struct CovidEntry: TimelineEntry {
    let date: Date
    let areaName: String
    let statistic: Statistic
    let configuration: CovidConfigurationIntent
    
    static let placeholder: CovidEntry = .init(
        date: .now,
        areaName: "Москва",
        statistic: .init(
            cases: 1000,
            cured: 1000,
            deaths: 0
        ),
        configuration: CovidConfigurationIntent()
    )
}
