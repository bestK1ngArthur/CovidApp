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
    
    var mediumFormatted: String {
        Formatters.mediumDateFormatter.string(from: self)
    }
}

struct Formatters {
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_ru")
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    static let mediumDateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_ru")
        formatter.dateFormat = "dd MMMM, yyyy"
        return formatter
    }()
}
