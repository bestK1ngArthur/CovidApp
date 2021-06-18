//
//  ListAreaView.swift
//  CovidApp
//
//  Created by Artem Belkov on 18.10.2020.
//

import SwiftUI

struct ListAreaView: View {
    @State var viewModel: ListAreaViewModel

    var body: some View {
        NavigationLink(
            destination: AreaView(
                viewModel: .init(
                    .init(
                        code: viewModel.code,
                        kind: viewModel.kind
                    )
                )
            )
        ) {
            HStack {
                Text(viewModel.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing) {
                    HStack {
                        if let vaccinatedPercentage = viewModel.vaccinatedPercentage {
                            Text(String(format: "%.1f", vaccinatedPercentage * 100) + "%")
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .font(.caption)
                        }
                        Text("-\(viewModel.statistic.deaths)")
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundColor(.red)
                    }
                    .frame(alignment: .trailing)
                    Text("+\(viewModel.statistic.cases)")
                        .font(.title)
                        .frame(alignment: .trailing)
                        .lineLimit(1)
                        .foregroundColor(.orange)
                }
            }
            .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.secondaryBackground)
            .cornerRadius(16)
        }
        .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

struct MainAreaView_Previews: PreviewProvider {
    static var previews: some View {
        ListAreaView(
            viewModel: .init(
                code: "213",
                kind: .russianState,
                name: "Москва",
                statistic: .empty,
                vaccinatedPercentage: nil
            )
        )
    }
}
