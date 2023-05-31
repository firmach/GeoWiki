//
//  Endpoint.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


enum HTTPMethod: String {
    case get = "GET"
}


protocol Endpoint{

    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var httpMethod: HTTPMethod { get }
    var httpBody: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}
