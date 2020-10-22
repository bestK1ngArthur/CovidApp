//
//  CovidDataSource.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import Foundation
import Combine

class CovidDataSource {
    static let shared: CovidDataSource = .init()
    
    func dataPublisher() -> AnyPublisher<CovidData, CovidError> {

        session.dataTaskPublisher(for: dataURL)
            .tryCompactMap {
                try JSONSerialization.jsonObject(with: $0.data, options: []) as? Raw
            }
            .tryMap { [unowned self] raw in
                CovidData(
                    russianStates: try self.parseAreas(from: raw, for: .russianState),
                    countries: try self.parseAreas(from: raw, for: .country)
                )
            }
            .mapError { _ in CovidError.networkError }
            .eraseToAnyPublisher()
    }
    
    func areaDataPublisher(_ request: AreaRequest) -> AnyPublisher<Area, CovidError> {
        
        let datesPublisher: AnyPublisher<[Date], CovidError> = session.dataTaskPublisher(for: dataURL)
            .tryCompactMap {
                try JSONSerialization.jsonObject(with: $0.data, options: []) as? Raw
            }
            .tryMap { [unowned self] raw in
                try parseDates(from: raw, for: request.kind)
            }
            .mapError { _ in CovidError.networkError }
            .eraseToAnyPublisher()
        
        let areaRawPublisher: AnyPublisher<Raw, CovidError> = session.dataTaskPublisher(for: areaURL(for: request))
            .tryCompactMap {
                try JSONSerialization.jsonObject(with: $0.data, options: []) as? Raw
            }
            .mapError { _ in CovidError.networkError }
            .eraseToAnyPublisher()

        return areaRawPublisher.combineLatest(datesPublisher)
            .tryMap { [unowned self] raw, dates in
                try self.parseArea(from: raw, code: request.code, kind: request.kind, dates: dates)
            }
            .mapError { _ in CovidError.parsingError }
            .eraseToAnyPublisher()
    }
    
    private typealias Raw = [String: Any]
    
    private let session = URLSession.shared
    
    private let basePath = "https://yastat.net/s3/milab/2020/covid19-stat/data"
    private let apiVersion = "1"

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var dataURL: URL {
        return url(with: "default_data.json")
    }

    private func areaURL(for request: AreaRequest) -> URL {
        return url(with: "data-by-region/\(request.code).json")
    }
    
    private func key(for kind: Area.Kind) -> String {
        switch kind {
        case .russianState: return "russia_stat_struct"
        case .country: return "world_stat_struct"
        }
    }
    
    private func url(with component: String) -> URL {
        var components = URLComponents(string: basePath)!
        
        components.queryItems = [.init(name: "v", value: apiVersion)]
        
        return components.url!.appendingPathComponent(component)
    }
    
    private func parseAreas(from raw: Raw, for kind: Area.Kind) throws -> [Area] {
        guard let areasRaw = raw[key(for: kind)] as? Raw,
              let data = areasRaw["data"] as? [String: Raw] else {
            throw CovidError.parsingError
        }

        let dates = try parseDates(from: raw, for: kind)
        
        let areas: [Area] = try data.map { code, rawArea in
            try self.parseArea(from: rawArea, code: code, kind: kind, dates: dates)
        }
        
        return areas.sorted { first, second in
            first.name < second.name
        }
    }
    
    private func parseDates(from raw: Raw, for kind: Area.Kind) throws -> [Date] {
        guard let areasRaw = raw[key(for: kind)] as? Raw,
              let datesRaw = areasRaw["dates"] as? [String] else {
            throw CovidError.parsingError
        }

        let dates = datesRaw.compactMap { raw in
            dateFormatter.date(from: raw)
        }
        
        return dates
    }

    
    private func parseArea(from raw: Raw, code: Area.Code, kind: Area.Kind, dates: [Date]? = nil) throws -> Area {
        guard let infoRaw = raw["info"] as? Raw,
              let name = infoRaw["name"] as? String,
              let population = infoRaw["population"] as? Int,
              let allCases = infoRaw["cases"] as? Int,
              let dailyCases = infoRaw["cases_delta"] as? Int,
              let allDeaths = infoRaw["deaths"] as? Int,
              let dailyDeaths = infoRaw["deaths_delta"] as? Int,
              let allCured = infoRaw["cured"] as? Int,
              let dailyCured = infoRaw["cured_delta"] as? Int else {
            throw CovidError.parsingError
        }

        let allTimeStatistic = Statistic(
            cases: allCases,
            cured: allCured,
            deaths: allDeaths
        )
        
        let dailyStatistic = Statistic(
            cases: dailyCases,
            cured: dailyCured,
            deaths: dailyDeaths
        )

        var timeline: StatisticTimeline? = nil
        
        if let dates = dates, dates.isNotEmpty,
           let rawCases = raw["cases"] as? [[Int]],
           let rawCured = raw["cured"] as? [[Int]],
           let rawDeaths = raw["deaths"] as? [[Int]] {
            guard dates.count <= rawCases.count,
                  rawCases.count == rawCured.count,
                  rawCured.count == rawDeaths.count else {
                throw CovidError.invalidStatisticTimeline
            }
            
            func mapEvents(for valueIndex: Int) -> [StatisticTimelineEvent] {
                dates.enumerated().map { index, date in
                    .init(
                        date: date,
                        statistic: .init(
                            cases: rawCases[index][valueIndex],
                            cured: rawCured[index][valueIndex],
                            deaths: rawDeaths[index][valueIndex]
                        )
                    )
                }
            }
            
            timeline = .init(
                allTime: mapEvents(for: 0),
                daily: mapEvents(for: 1)
            )
        }
        
        return Area(
            code: code,
            kind: kind,
            name: name,
            population: population,
            allTimeStatistic: allTimeStatistic,
            dailyStatistic: dailyStatistic,
            statisticTimeline: timeline
        )
    }
}
