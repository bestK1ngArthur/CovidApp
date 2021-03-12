//
//  CovidModels.swift
//  CovidApp
//
//  Created by Artem Belkov on 22.10.2020.
//

import Foundation

struct Statistic {
    let cases: Int
    let deaths: Int
    let vaccinated: Int?
    let fullyVaccinated: Int?
    
    static let empty: Statistic = .init(
        cases: 0,
        deaths: 0,
        vaccinated: nil,
        fullyVaccinated: nil
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
    
    var vaccinatedPercentage: Double? {
        guard let fullyVaccinated = allTimeStatistic.fullyVaccinated else {
            return nil
        }

        return Double(fullyVaccinated) / Double(population)
    }
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
