//
//  CovidDataSource.swift
//  Covid19
//
//  Created by Artem Belkov on 16.10.2020.
//

import Foundation
import Combine

struct Statistic {
    let cases: Int
    let cured: Int
    let deaths: Int
}

struct Area: Identifiable {
    let name: String
    let population: Int
    let allTimeStatistic: Statistic
    let todayStatistic: Statistic
    let timelineStatistics: [Statistic]
    
    let id = UUID()
}

struct CovidData {
    let russianAreas: [Area]
    let countries: [Area]
}

enum CovidError: Error {
    case networkError
    case parsingError
}

typealias Raw = [String: Any]

class CovidDataSource {
    
    static let shared: CovidDataSource = .init()
    
    func dataPublisher() -> AnyPublisher<CovidData, CovidError> {
        session.dataTaskPublisher(for: dataURL)
            .tryCompactMap {
                try JSONSerialization.jsonObject(with: $0.data, options: []) as? Raw
            }
            .tryMap { [unowned self] raw in
                CovidData(
                    russianAreas: try self.parseAreas(from: raw, for: "russia_stat_struct"),
                    countries: try self.parseAreas(from: raw, for: "world_stat_struct")
                )
            }
            .mapError { _ in CovidError.networkError }
            .eraseToAnyPublisher()
    }
    
    private let session = URLSession.shared
    private let dataURL = URL(string: "https://yastat.net/s3/milab/2020/covid19-stat/data/default_data.json")!
    
    private func parseAreas(from raw: Raw, for key: String) throws -> [Area] {
        guard let areasRaw = raw[key] as? Raw,
              let data = areasRaw["data"] as? [String: Raw] else {
            throw CovidError.parsingError
        }
        
        let areas: [Area] = data.values.compactMap { raw in
            guard let infoRaw = raw["info"] as? Raw,
                  let name = infoRaw["name"] as? String,
                  let population = infoRaw["population"] as? Int,
                  let allCases = infoRaw["cases"] as? Int,
                  let todayCases = infoRaw["cases_delta"] as? Int,
                  let allDeaths = infoRaw["deaths"] as? Int,
                  let todayDeaths = infoRaw["deaths_delta"] as? Int,
                  let allCured = infoRaw["cured"] as? Int,
                  let todayCured = infoRaw["cured_delta"] as? Int else {
                return nil
            }

            let allTimeStatistic = Statistic(
                cases: allCases,
                cured: allCured,
                deaths: allDeaths
            )
            
            let todayStatistic = Statistic(
                cases: todayCases,
                cured: todayCured,
                deaths: todayDeaths
            )
            
            // TODO: Add time statistics
            
            return Area(
                name: name,
                population: population,
                allTimeStatistic: allTimeStatistic,
                todayStatistic: todayStatistic,
                timelineStatistics: []
            )
        }
        
        return areas.sorted { first, second in
            first.name < second.name
        }
    }
}
