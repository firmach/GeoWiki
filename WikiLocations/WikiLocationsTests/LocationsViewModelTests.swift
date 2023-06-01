//
//  LocationsViewModelTests.swift
//  WikiLocationsTests
//
//  Created by Roman Churkin on 01/06/2023.
//

import XCTest
import Combine
@testable import WikiLocations

final class LocationsViewModelTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    @MainActor
    func testFetchLocationsSuccess() {
        let mockService = MockLocationsService()
        mockService.fetchLocationsResult = .success(
            LocationsResponse(
                locations: [
                    Location(name: "Great Pyramid of Giza", lat: 29.9792, long: 31.1342),
                    Location(name: "Great Wall of China", lat: 40.4319, long: 116.5704),
                    Location(name: "Machu Picchu", lat: -13.1631, long: -72.5450)
                ]
            )
        )

        let dependencies = MockLocationsViewModelDependencies(locationsService: mockService)
        let viewModel = LocationsViewModel(dependencies: dependencies)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.locations.count, 0)

        let expectationLoadingSet = XCTestExpectation(description: "isLoading set")
        let expectationLocationsSet = XCTestExpectation(description: "locations set")
        let expectationErrorMessageSetNil = XCTestExpectation(description: "errorMessage reset")

        var count = 0
        viewModel.$isLoading
            .sink { isLoading in
                switch count {
                case 1:
                    XCTAssertTrue(isLoading)
                    expectationLoadingSet.fulfill()
                case 2:
                    XCTAssertFalse(isLoading)
                    expectationErrorMessageSetNil.fulfill()
                default: break
                }
                count += 1
            }
            .store(in: &cancellables)

        viewModel.$locations
            .dropFirst(1)
            .sink { locations in
                XCTAssertEqual(locations.count, 3)
                XCTAssertEqual(locations[0].name, "Great Pyramid of Giza")
                XCTAssertEqual(locations[0].lat, 29.9792)
                XCTAssertEqual(locations[0].long, 31.1342)
                XCTAssertEqual(locations[2].name, "Machu Picchu")
                XCTAssertEqual(locations[2].lat, -13.1631)
                XCTAssertEqual(locations[2].long, -72.5450)
                expectationLocationsSet.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchLocations()

        wait(for: [expectationLoadingSet, expectationLocationsSet], timeout: 0.25)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.locations.count, 3)

        wait(for: [expectationErrorMessageSetNil], timeout: 0.25)
    }

    @MainActor
    func testFetchLocationsFailure() {
        let mockService = MockLocationsService()
        mockService.fetchLocationsResult = .failure(NetworkError.noResponse)

        let dependencies = MockLocationsViewModelDependencies(locationsService: mockService)
        let viewModel = LocationsViewModel(dependencies: dependencies)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.locations.count, 0)

        let expectationErrorMessageSetSome = XCTestExpectation(description: "errorMessage set")

        viewModel.$errorMessage
            .filter { $0 != nil }
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectationErrorMessageSetSome.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchLocations()

        wait(for: [expectationErrorMessageSetSome], timeout: 0.25)

        XCTAssertEqual(viewModel.errorMessage, "Something wrong happened. Try again later.\n\(NetworkError.noResponse.localizedDescription)")
        XCTAssertEqual(viewModel.locations.count, 0)
    }
}


struct MockLocationsViewModelDependencies: LocationsViewModelDependencies {
    var locationsService: LocationsServiceProtocol
}


final class MockLocationsService: LocationsServiceProtocol {

    var fetchLocationsResult: Result<LocationsResponse, NetworkError>!

    func fetchLocations() async -> Result<LocationsResponse, NetworkError> {
        try! await Task.sleep(nanoseconds: 500_000)
        return fetchLocationsResult
    }
}
