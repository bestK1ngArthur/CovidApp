//
//  CovidWidget.swift
//  CovidWidget
//
//  Created by Artem Belkov on 17.10.2020.
//

import SwiftUI
import WidgetKit
import Charts

struct CovidWidgetEntryView: View {
    var entry: CovidEntry

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(entry.areaName)
                    .font(.headline)
                    .minimumScaleFactor(0.4)
                    .lineLimit(2)
                Spacer()
                Text(entry.date.shortFormatted)
                    .font(.callout)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Chart(data: entry.timelineData)
                .chartStyle(
                    AreaChartStyle(.quadCurve, fill: LinearGradient(
                                    gradient: .init(colors: [Color.orange, Color.orange.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom)
                    )
                )
            Spacer()
            HStack {
                Spacer()
                Text("-\(entry.statistic.cured)")
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .font(.caption)
                Text("-\(entry.statistic.deaths)")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.red)
            }
            Text("+\(entry.statistic.cases)")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineLimit(1)
                .foregroundColor(.orange)
        }
        .padding(16)
    }
}

@main
struct CovidWidget: Widget {
    let kind: String = "CovidWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: CovidConfigurationIntent.self, provider: CovidProvider()) { entry in
            CovidWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Статистика Covid19")
        .description("Мониторинг статистики заражения коронавирусом.")
    }
}

struct CovidWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CovidWidgetEntryView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            CovidWidgetEntryView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            CovidWidgetEntryView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
