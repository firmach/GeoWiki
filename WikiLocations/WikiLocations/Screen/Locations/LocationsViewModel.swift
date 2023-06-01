//
//  LocationsViewModel.swift
//  WikiLocations
//
//  Created by Roman Churkin on 31/05/2023.
//

import Foundation
import Combine


protocol LocationsViewModelDependencies {
    var locationsService: LocationsServiceProtocol { get }
}


struct DefaultLocationsViewModelDependencies: LocationsViewModelDependencies {
    let locationsService: LocationsServiceProtocol

    init() {
        locationsService = LocationsService(apiClient: DefaultAPIClient())
    }
}


@MainActor
final class LocationsViewModel {

    // MARK: - Observable properties

    @Published private(set) var locations: [Location] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil


    // MARK: - Private properties

    private let locationsService: LocationsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(dependencies: LocationsViewModelDependencies) {
        locationsService = dependencies.locationsService
    }

    func fetchLocations() {
        guard isLoading == false else { return }

        self.errorMessage = nil
        self.isLoading = true

        Task {
            let result = await locationsService.fetchLocations()
                self.isLoading = false
                switch result {
                case .success(let response):
                    self.locations += response.locations

                case .failure(let error):
                    let message = "Something wrong happened. Try again later.\n\(error.localizedDescription)"
                    self.errorMessage = message
                }
        }
    }

}
