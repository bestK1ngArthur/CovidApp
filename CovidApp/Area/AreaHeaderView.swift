//
//  AreaHeaderView.swift
//  CovidApp
//
//  Created by Artem Belkov on 22.10.2020.
//

import SwiftUI

struct AreaHeaderView: View {
    let name: String
    let statistic: Statistic
    
    var body: some View {
        Text(name)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 28, weight: .bold))
        HStack {
            Text("+\(statistic.cases)")
                .font(.title)
                .lineLimit(1)
                .foregroundColor(.orange)
            Text("-\(statistic.cured)")
                .font(.title)
                .lineLimit(1)
                .font(.caption)
                .foregroundColor(.green)
            Text("-\(statistic.deaths)")
                .font(.title)
                .lineLimit(1)
                .foregroundColor(.red)
            Spacer()
        }
    }
}

struct AreaHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        AreaHeaderView(
            name: "Москва",
            statistic: .zero
        )
    }
}
