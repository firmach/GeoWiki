//
//  LocationsService.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation


protocol LocationsServiceProtocol {

    func fetchLocations() async -> Result<LocationsResponse, NetworkError>

}


struct LocationsService: LocationsServiceProtocol {

    let apiClient: APIClient

    init(apiClient: APIClient) { self.apiClient = apiClient }

    func fetchLocations() async -> Result<LocationsResponse, NetworkError> {
        let endpoint = LocationsEndpoint()
        return await apiClient.sendRequest(endpoint, ofType: LocationsResponse.self)
    }

}
