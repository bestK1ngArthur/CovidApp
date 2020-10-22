//
//  CovidModels.swift
//  CovidApp
//
//  Created by Artem Belkov on 22.10.2020.
//

import Foundation

struct Statistic {
    let cases: Int
    let cured: Int
    let deaths: Int
    
    static let zero = Statistic(
        cases: 0,
        cured: 0,
        deaths: 0
    )
}

struct StatisticTimeline {
    let allTime: [StatisticTimelineEvent]
    let daily: [StatisticTimelineEvent]
}

struct StatisticTimelineEvent: Identifiable {
    let date: Date
    let statistic: Statistic
    
    let id = UUID()
}

struct Area {
    typealias Code = String

    enum Kind {
        case country
        case russianState
    }
    
    let code: Code
    let kind: Kind
    let name: String
    let population: Int
    let allTimeStatistic: Statistic
    let dailyStatistic: Statistic
    
    let statisticTimeline: StatisticTimeline?
}

struct AreaRequest {
    let code: Area.Code
    let kind: Area.Kind
}

struct CovidData {
    let russianStates: [Area]
    let countries: [Area]
}

enum CovidError: Error {
    case networkError
    case parsingError
    case invalidStatisticTimeline
    case emptyDates
}
