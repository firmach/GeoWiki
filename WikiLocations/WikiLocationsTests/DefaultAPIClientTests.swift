//
//  DefaultAPIClientTests.swift
//  WikiLocationsTests
//
//  Created by Roman Churkin on 31/05/2023.
//

import XCTest
@testable import WikiLocations

final class DefaultAPIClientTests: XCTestCase {

    // Define the test endpoint
    struct TestEndpoint: Endpoint {
        var scheme: String = "test"
        var host: String = "test"
        var headers: [String : String]? = nil
        var path: String { "/test" }
        var httpMethod: HTTPMethod { .get }
        var queryItems: [URLQueryItem]? { nil }
        var httpBody: Data? { nil }
    }

    // Test data for the Location response
    let locationResponseData = """
        {
        "locations": [{
            "name": "Great Pyramid of Giza",
            "lat": 29.9792,
            "long": 31.1342
        }, {
            "lat": 41.8902,
            "long": 12.4922
        }, {
            "name": "Statue of Liberty",
            "lat": 40.6892,
            "long": -74.0445
        }, {
            "name": "Taj Mahal",
            "lat": 27.1751,
            "lon": 78.0421
        }]
        }
        """.data(using: .utf8)

    // Testing the DefaultAPIClient success scenario
    func testSuccessLocationRequest() async {
        let mockURLSession = MockURLSession()
        let apiClient = DefaultAPIClient(session: mockURLSession)
        let testEndpoint = TestEndpoint()
        let urlComponents = URLComponents(endpoint: testEndpoint)
        let url = urlComponents.url!
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.mockResponse = (locationResponseData, httpResponse, nil)

        let result = await apiClient.sendRequest(testEndpoint, ofType: LocationsResponse.self)
        switch result {
        case .success(let response):
            XCTAssertEqual(response.locations.count, 3)
            XCTAssertEqual(response.locations[0].name, "Great Pyramid of Giza")
            XCTAssertEqual(response.locations[0].lat, 29.9792)
            XCTAssertEqual(response.locations[0].long, 31.1342)
            XCTAssertNil(response.locations[1].name)
            XCTAssertEqual(response.locations[2].lat, 40.6892)
            XCTAssertEqual(response.locations[2].long, -74.0445)
        case .failure(let error):
            XCTFail("Expected success but received error: \(error)")
        }
    }

    // Testing the DefaultAPIClient failure scenario (incorrect response)
    func testFailOnIncorrectResponse() async {
        let mockURLSession = MockURLSession()
        let apiClient = DefaultAPIClient(session: mockURLSession)
        let testEndpoint = TestEndpoint()
        let urlComponents = URLComponents(endpoint: testEndpoint)
        let url = urlComponents.url!
        let incorrectData = """
        {
            "no": "response",
        }
        """.data(using: .utf8)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.mockResponse = (incorrectData, httpResponse, nil)

        let result = await apiClient.sendRequest(testEndpoint, ofType: LocationsResponse.self)
        switch result {
        case .success:
            XCTFail("Expected error but received success")
        case .failure:
            break
        }
    }

    class MockURLSession: URLSessionProtocol {

        var mockResponse: (Data?, URLResponse?, Error?) = (nil, nil, nil)

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            return try await withCheckedThrowingContinuation { continuation in
                guard let data = mockResponse.0, let response = mockResponse.1 else {
                    continuation.resume(throwing: mockResponse.2 ?? NetworkError.noResponse)
                    return
                }
                continuation.resume(returning: (data, response))
            }
        }
    }

}
