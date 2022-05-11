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
    
    enum PlacesError {
        case failedtoFind
    }
    
    public func setUp() {
        GMSPlacesClient.provideAPIKey("AIzaSyBYNt5TQ3boWobJJoRYulZeI-yRf5WMQcY")
    }
    
    public func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], Error> ) -> Void
    ) {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        self.client.findAutocompletePredictions(
            fromQuery: query, filter: filter, sessionToken: nil
        ) {
            results, error in
             guard let results = results, error == nil else {
                 completion(.failure(PlacesError.failedtoFind as! Error))
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
