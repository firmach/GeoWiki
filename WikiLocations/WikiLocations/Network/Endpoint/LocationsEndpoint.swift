//
//  LocationsEndpoint.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


struct LocationsEndpoint: Endpoint {

    var scheme: String = "https"
    var host: String = "raw.githubusercontent.com"
    var path: String = "/abnamrocoesd/assignment-ios/main/locations.json"
    var headers: [String : String]? = nil
    var httpMethod: HTTPMethod = .get
    var httpBody: Data? = nil
    var queryItems: [URLQueryItem]? = nil

}
