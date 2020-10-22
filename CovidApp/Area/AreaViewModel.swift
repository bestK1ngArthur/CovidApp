//
//  AreaViewModel.swift
//  CovidApp
//
//  Created by Artem Belkov on 18.10.2020.
//

import Foundation
import Combine
import SwiftUI

class AreaViewModel: ObservableObject {
    let request: AreaRequest
    
    @Published var name: String = ""
    @Published var statistic: Statistic = .zero
    
    @Published var timeInterval: TimeInterval = .week
    @Published var rateType: RateType = .cases
    @Published var timelineColor: Color = .orange
    @Published var timelineData: [Float] = []

    @Published var timelineEvents: [StatisticTimelineEvent] = []
    
    var isLoading: Bool { name.isEmpty }
    
    init(_ request: AreaRequest) {
        self.request = request
        
        let updateInterval = $timeInterval.sink { [unowned self] timeInterval in
            self.timelineData = self.timelineData(from: self.timelineEvents, timeInterval: timeInterval, rateType: self.rateType)
        }
        
        bag.insert(updateInterval)

        let updateRate = $rateType.sink { [unowned self] rateType in
            self.timelineData = self.timelineData(from: self.timelineEvents, timeInterval: self.timeInterval, rateType: rateType)
            self.timelineColor = {
                switch rateType {
                case .cases: return .orange
                case .cured: return .green
                case .deaths: return .red
                }
            }()
        }
        
        bag.insert(updateRate)
    }
    
    func loadData() {
        let areaRequest = CovidDataSource.shared.areaDataPublisher(request)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [unowned self] area in
                    DispatchQueue.main.async {
                        let timelineEvents = area.statisticTimeline?.daily ?? []
                        
                        self.name = area.name
                        self.statistic = area.dailyStatistic
                        self.timelineData = self.timelineData(
                            from: timelineEvents,
                            timeInterval: self.timeInterval,
                            rateType: self.rateType
                        )
                        self.timelineEvents = timelineEvents
                    }
                  })
        
        bag.insert(areaRequest)
    }
    
    private var bag: Set<AnyCancellable> = []
    
    private func timelineData(from events: [StatisticTimelineEvent],
                              timeInterval: TimeInterval,
                              rateType: RateType) -> [Float] {
        var suffix: Int {
            switch timeInterval {
            case .week: return 7
            case .month: return 30
            case .allTime: return .max
            }
        }
        
        let data: [Float] = events
            .map {
                switch rateType {
                case .cases: return Float($0.statistic.cases)
                case .cured: return Float($0.statistic.cured)
                case .deaths: return Float($0.statistic.deaths)
                }
            }
            .suffix(suffix)
        
        guard let maxValue = data.max() else { return [] }

        let normalizedData = data
            .map { value in value / maxValue }
        
        return normalizedData
    }
}

extension AreaViewModel {
    
    enum TimeInterval: String, CaseIterable, Identifiable {
        case week = "неделя"
        case month = "месяц"
        case allTime = "всё время"
        
        var id: String { rawValue }
    }
    
    enum RateType: String, CaseIterable, Identifiable {
        case cases = "🦠"
        case cured = "💊"
        case deaths = "💀"
        
        var id: String { rawValue }
    }
}
