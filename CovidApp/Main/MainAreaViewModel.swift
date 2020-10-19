//
//  MainAreaViewModel.swift
//  CovidApp
//
//  Created by Artem Belkov on 18.10.2020.
//

import Foundation

struct MainAreaViewModel: Identifiable {
    let code: String
    let kind: Area.Kind
    let name: String
    let statistic: Statistic
    
    let id = UUID()
}
