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
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AreaHeaderView(name: viewModel.name, statistic: viewModel.statistic)
                AreaSectionView("Interval") {
                    Picker("Interval", selection: $viewModel.timeInterval) {
                        ForEach(AreaViewModel.TimeInterval.allCases) { interval in
                            Text(LocalizedStringKey(interval.rawValue)).tag(interval)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                AreaSectionView("Rate") {
                    Picker("Rate", selection: $viewModel.rateType) {
                        ForEach(AreaViewModel.RateType.allCases) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                AreaSectionView("Chart") {
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
                }
                AreaSectionView("All data") {
                    ForEach(viewModel.timelineEvents) { event in
                        VStack {
                            Text(event.date.mediumFormatted)
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
                    HStack {
                        Text("Date from ")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Link("yandex.ru", destination: URL(string: "https://yandex.ru/covid19/stat/widget/default/")!)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.leading, -8)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
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
