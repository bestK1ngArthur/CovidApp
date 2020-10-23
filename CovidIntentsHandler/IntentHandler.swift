//
//  IntentHandler.swift
//  CovidIntentsHandler
//
//  Created by Artem Belkov on 17.10.2020.
//

import Intents
import Combine

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    private var cancelation: Cancellable?
}

extension IntentHandler: CovidConfigurationIntentHandling {
    func provideAreaOptionsCollection(for intent: CovidConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<AreaCode>?, Error?) -> Void) {
        cancelation = CovidDataSource.shared.dataPublisher()
            .sink(receiveCompletion: { error in
                switch error {
                case .failure(let error):
                    completion(nil, error)
                case .finished:
                    break
                }
            }, receiveValue: { data in
                                
                func createSection(from areas: [Area], with title: String) -> INObjectSection<AreaCode> {
                    let areasCodes: [AreaCode] = areas
                        .filter { area in
                            guard let searchTerm = searchTerm?.lowercased() else { return true }
                            
                            let areaName = area.name.lowercased()
                            return areaName.contains(searchTerm)
                        }
                        .map { area in
                            let areaCode = AreaCode(identifier: area.code, display: area.name)

                            if case .country = area.kind {
                                areaCode.isCountry = NSNumber(booleanLiteral: true)
                            } else {
                                areaCode.isCountry = NSNumber(booleanLiteral: false)
                            }

                            return areaCode
                        }
                    
                    let localizedTitle = NSLocalizedString(title, comment: "")

                    return INObjectSection(title: localizedTitle, items: areasCodes)
                }
                                
                let collection = INObjectCollection(sections: [
                    createSection(from: data.russianStates, with: "Russian states"),
                    createSection(from: data.countries, with: "Countries")
                ])
                
                completion(collection, nil)
            })
    }
    
    func defaultArea(for intent: CovidConfigurationIntent) -> AreaCode? {
        let areaCode = AreaCode(identifier: "213", display: "Москва")
        areaCode.isCountry = NSNumber(booleanLiteral: false)
        return areaCode
    }
}
