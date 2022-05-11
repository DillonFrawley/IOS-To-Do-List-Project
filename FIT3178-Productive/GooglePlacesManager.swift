//
//  GooglePlacesManager.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 11/5/2022.
//

import Foundation
import GooglePlaces

struct Place {
    let name: String
    let identifier: String
}

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    
    
    private init () {
    }
    
    enum PlacesError: Error {
        case failedtoFind
    }
        
    public func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], Error> ) -> Void
    ) {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(
            fromQuery: query, filter: filter, sessionToken: nil
        ) {
            results, error in
             guard let results = results, error == nil else {
                 completion(.failure(PlacesError.failedtoFind))
                return
            }
            
            let places: [Place] = results.compactMap({
                Place(
                    name: $0.attributedFullText.string,
                    identifier: $0.placeID
                )
            })
            
            completion(.success(places))
                                                                                                
         }
    }
                                                                                                
            
    
}
