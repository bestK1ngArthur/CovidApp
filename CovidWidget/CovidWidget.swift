//
//  CovidWidget.swift
//  CovidWidget
//
//  Created by Artem Belkov on 17.10.2020.
//

import SwiftUI
import Combine
import WidgetKit
import Intents

class CovidProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> CovidEntry {
        return .placeholder
    }

    func getSnapshot(for configuration: CovidConfigurationIntent, in context: Context, completion: @escaping (CovidEntry) -> ()) {
        loadArea(for: .init(code: "1", kind: .russianState)) { area in
            let entry = CovidEntry(
                date: .now,
                area: area,
                configuration: configuration
            )
            
            completion(entry)
        }
        
        completion(.placeholder)
    }

    func getTimeline(for configuration: CovidConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let code = configuration.area?.identifier,
              let isCountry = configuration.area?.isCountry?.boolValue else {
            return
        }
        
        let request = AreaRequest(
            code: code,
            kind: isCountry ? .country : .russianState
        )
        
        loadArea(for: request) { area in
            guard let updateDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now) else {
                return
            }
            
            let entry = CovidEntry(
                date: .now,
                area: area,
                configuration: configuration
            )
            
            let timeline = Timeline(entries: [entry], policy: .after(updateDate))

            completion(timeline)
        }
    }
    
    private func loadArea(for request: AreaRequest, completion: @escaping (Area) -> Void) {
        if cancellation != nil {
            cancellation?.cancel()
        }

        cancellation = CovidDataSource.shared.areaDataPublisher(request)
            .sink(receiveCompletion: { error in print(error) },
                  receiveValue: { area in completion(area) })
    }
    
    private var cancellation: AnyCancellable?
}

struct CovidEntry: TimelineEntry {
    let date: Date
    let area: Area
    let configuration: CovidConfigurationIntent
    
    static let placeholder: CovidEntry = .init(
        date: .now,
        area: Area(
            code: "1",
            kind: .russianState,
            name: "Москва",
            population: 1,
            allTimeStatistic: .init(
                cases: 1,
                cured: 1,
                deaths: 0
            ),
            dailyStatistic: .init(
                cases: 1,
                cured: 1,
                deaths: 0
            ),
            statisticTimeline: nil
        ),
        configuration: CovidConfigurationIntent()
    )
}

struct CovidWidgetEntryView: View {
    var entry: CovidEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.area.name).font(.headline)
            Text("Заражены: \(entry.area.allTimeStatistic.cases)")
            Text("Вылечилось: \(entry.area.allTimeStatistic.cured)")
            Text("Умерло: \(entry.area.allTimeStatistic.deaths)")
        }
    }
}

@main
struct CovidWidget: Widget {
    let kind: String = "CovidWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CovidConfigurationIntent.self, provider: CovidProvider()) { entry in
            CovidWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        CovidWidgetEntryView(entry: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
