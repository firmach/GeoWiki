//
//  URLComponents.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


extension URLComponents {

    init(endpoint: some Endpoint) {
        self.init()
        self.scheme = endpoint.scheme
        self.host = endpoint.host
        self.path = endpoint.path
        self.queryItems = endpoint.queryItems
    }

}
