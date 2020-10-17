//
//  Date+Extension.swift
//  CovidApp
//
//  Created by Artem Belkov on 17.10.2020.
//

import Foundation

extension Date {
    static var now: Date { .init() }
    
    var shortFormatted: String {
        Formatters.shortDateFormatter.string(from: self)
    }
}

struct Formatters {
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
}
