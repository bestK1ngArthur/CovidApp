//
//  AreaView.swift
//  CovidApp
//
//  Created by Artem Belkov on 18.10.2020.
//

import SwiftUI
import Charts

struct AreaView: View {
    @ObservedObject var viewModel: AreaViewModel
    
    @State var selection = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 28, weight: .bold))
                HStack {
                    Text("+\(viewModel.statistic.cases)")
                        .font(.title)
                        .lineLimit(1)
                        .foregroundColor(.orange)
                    Text("-\(viewModel.statistic.cured)")
                        .font(.title)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("-\(viewModel.statistic.deaths)")
                        .font(.title)
                        .lineLimit(1)
                        .foregroundColor(.red)
                    Spacer()
                }
                Text("Интервал")
                    .padding(.top, 8)
                    .font(.headline)
                Picker("Интервал", selection: $viewModel.timeInterval) {
                    ForEach(AreaViewModel.TimeInterval.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Показатель")
                    .padding(.top, 8)
                    .font(.headline)
                Picker("Показатель", selection: $viewModel.rateType) {
                    ForEach(AreaViewModel.RateType.allCases) { interval in
                        Text(interval.rawValue).tag(interval)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("График")
                    .padding(.top, 8)
                    .font(.headline)
                Chart(data: viewModel.timelineData)
                    .chartStyle(
                        AreaChartStyle(
                            .quadCurve,
                            fill: LinearGradient(
                                gradient: .init(
                                    colors: [viewModel.timelineColor, viewModel.timelineColor.opacity(0.05)]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    )
                    .frame(height: 200)
                Text("Все данные")
                    .padding(.vertical, 8)
                    .font(.headline)
                ForEach(viewModel.timelineEvents) { event in
                    VStack {
                        Text(event.date, style: .date)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .padding(.bottom, 2)
                        HStack {
                            Text("+\(event.statistic.cases)")
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(.orange)
                            Text("-\(event.statistic.cured)")
                                .font(.headline)
                                .lineLimit(1)
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("-\(event.statistic.deaths)")
                                .font(.headline)
                                .lineLimit(1)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .background(Color.secondaryBackground)
                    .cornerRadius(16)
                }
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            viewModel.loadData()
        }
    }
}

struct AreaView_Previews: PreviewProvider {
    static var previews: some View {
        AreaView(viewModel: .init(.init(code: "1", kind: .russianState)))
    }
}
