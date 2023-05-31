//
//  URLRequest.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


extension URLRequest {

    init(endpoint: some Endpoint) throws {
        let urlComponents = URLComponents(endpoint: endpoint)
        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        self.init(url: url)
        self.httpMethod = endpoint.httpMethod.rawValue
        self.allHTTPHeaderFields = endpoint.headers
        self.httpBody = endpoint.httpBody
    }

}
